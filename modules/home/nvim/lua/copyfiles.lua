-- lua/copyfiles.lua
-- Minimal helper to copy files/buffers to clipboard with a project-relative header line.
-- Commands:
--   :CopyFile                   -> current buffer
--   :CopyFiles {glob/paths...}  -> one or many files (globs allowed)
--   :CopyOpenBuffers[!] [modified]
--        - default: listed file buffers
--        - "!"     : include unlisted file buffers too
--        - "modified": only buffers with unsaved changes

------------------------------------------------------------
-- Config: file fence markers
------------------------------------------------------------
local START_TAG = "this is "
local END_TAG = " ends here"
local M = {}

------------------------------------------------------------
-- Root detection
------------------------------------------------------------
local function git_root_fallback()
  -- Fallback using Git if available
  local ok, out = pcall(vim.fn.systemlist, { "git", "rev-parse", "--show-toplevel" })
  if ok and out and out[1] and out[1] ~= "" and vim.v.shell_error == 0 then
    return out[1]
  end
end

local function get_project_root()
  -- 1) LSP workspace root, if any
  local ok_ws, ws = pcall(vim.lsp.buf.list_workspace_folders)
  if ok_ws and ws and #ws > 0 then
    -- Some servers return multiple; we take the first
    return ws[1]
  end

  -- 2) Git repo root (via vim.fs.find if available)
  if vim.fs and vim.fs.find then
    local git_dir = vim.fs.find(".git", { upward = true, type = "directory" })[1]
    if git_dir then
      local root = vim.fs.dirname(git_dir)
      if root and #root > 0 then
        return root
      end
    end
  end

  -- 2b) Git fallback via CLI
  local gr = git_root_fallback()
  if gr then
    return gr
  end

  -- 3) Fallback to current working dir
  return vim.loop.cwd()
end

------------------------------------------------------------
-- Paths & file IO
------------------------------------------------------------
local function rel_to_root(abs_path, root)
  abs_path = vim.fn.fnamemodify(abs_path, ":p") -- normalize
  root = vim.fn.fnamemodify(root, ":p")
  if abs_path:sub(1, #root) == root then
    local rel = abs_path:sub(#root + 1)
    if rel:sub(1, 1) == "/" or rel:sub(1, 1) == "\\" then
      rel = rel:sub(2)
    end
    return rel
  end
  return vim.fn.fnamemodify(abs_path, ":t") -- fallback to filename only
end

local function readfile(path)
  -- Returns a string with \n line endings (even on Windows).
  local ok, lines = pcall(vim.fn.readfile, path, "")
  if not ok then
    return nil, ("Failed to read %s"):format(path)
  end
  return table.concat(lines, "\n")
end

local function expand_args_to_files(argstr)
  if not argstr or argstr == "" then
    return {}
  end
  local files = {}
  for _, pat in ipairs(vim.split(argstr, "%s+")) do
    if pat ~= "" then
      local matched = vim.fn.glob(pat, false, true)
      if #matched == 0 then
        table.insert(files, pat) -- allow direct paths that don't glob-expand
      else
        for _, m in ipairs(matched) do
          table.insert(files, m)
        end
      end
    end
  end
  return files
end

------------------------------------------------------------
-- Clipboard
------------------------------------------------------------
local function copy_to_clipboard(text)
  -- Try '+' (unnamedplus) and '*' (primary) for broader compatibility.
  local ok_plus = pcall(vim.fn.setreg, "+", text)
  local ok_star = pcall(vim.fn.setreg, "*", text)
  if ok_plus or ok_star then
    return true
  end
  vim.notify("No clipboard provider found (xclip/xsel/wl-copy/clip.exe).", vim.log.levels.WARN)
  return false
end

------------------------------------------------------------
-- Assembly (files)
------------------------------------------------------------
local function wrap_with_fences(header, body)
  if not body:match("\n$") then
    body = body .. "\n"
  end
  return table.concat({
    START_TAG,
    header,
    ":\n",
    body,
    "\n\n",
  })
end

local function assemble_payload_from_paths(paths)
  local root = get_project_root()
  local chunks = {}

  for _, p in ipairs(paths) do
    local abs = vim.fn.fnamemodify(p, ":p")
    local header = rel_to_root(abs, root)
    local body, err = readfile(abs)
    if not body then
      local faux = ("<ERROR: %s>\n"):format(err)
      table.insert(chunks, wrap_with_fences(header, faux))
    else
      table.insert(chunks, wrap_with_fences(header, body))
    end
  end

  return table.concat(chunks, "")
end

------------------------------------------------------------
-- Assembly (buffers)
------------------------------------------------------------
local function get_buf_body(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return table.concat(lines, "\n")
end

local function assemble_payload_from_buffers(bufs)
  local root = get_project_root()
  local chunks, seen = {}, {}

  for _, b in ipairs(bufs) do
    local name = vim.api.nvim_buf_get_name(b)
    if name and name ~= "" then
      local abs = vim.fn.fnamemodify(name, ":p")
      if not seen[abs] then
        seen[abs] = true
        local header = rel_to_root(abs, root)
        local body = table.concat(vim.api.nvim_buf_get_lines(b, 0, -1, false), "\n")
        table.insert(chunks, wrap_with_fences(header, body))
      end
    end
  end

  return table.concat(chunks, "")
end

------------------------------------------------------------
-- Public actions
------------------------------------------------------------
function M.copy_current_file()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("No file on this buffer.", vim.log.levels.WARN)
    return
  end
  local payload = assemble_payload_from_paths({ path })
  if copy_to_clipboard(payload) then
    vim.notify("Copied current file with project-relative header.", vim.log.levels.INFO)
  end
end

function M.copy_files_cmd(opts)
  local files = expand_args_to_files(opts.args)
  if #files == 0 then
    vim.notify("No files matched.", vim.log.levels.WARN)
    return
  end
  local payload = assemble_payload_from_paths(files)
  if copy_to_clipboard(payload) then
    vim.notify(("Copied %d file(s) with headers."):format(#files), vim.log.levels.INFO)
  end
end

function M.copy_open_buffers(opts)
  -- opts.bang      -> include unlisted buffers as well
  -- opts.args=="modified" -> only include modified buffers
  local include_unlisted = opts.bang or false
  local only_modified = (opts.args == "modified")

  local bufs = vim.api.nvim_list_bufs()
  local pick = {}

  for _, b in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(b) then
      local listed_ok = include_unlisted or vim.bo[b].buflisted
      local is_filetype = (vim.bo[b].buftype == "")
      local name = vim.api.nvim_buf_get_name(b) or ""
      local has_name = name ~= ""
      local scheme_ok = has_name and not name:match("^[%a%d]+://")
      local modified_ok = (not only_modified) or vim.bo[b].modified

      if listed_ok and is_filetype and has_name and scheme_ok and modified_ok then
        table.insert(pick, b)
      end
    end
  end

  if #pick == 0 then
    vim.notify("No matching open buffers.", vim.log.levels.WARN)
    return
  end

  local payload = assemble_payload_from_buffers(pick)
  if copy_to_clipboard(payload) then
    vim.notify(("Copied %d buffer(s) with headers."):format(#pick), vim.log.levels.INFO)
  end
end

------------------------------------------------------------
-- Setup & commands
------------------------------------------------------------
function M.setup()
  vim.api.nvim_create_user_command("CopyFile", function()
    M.copy_current_file()
  end, {})
  vim.api.nvim_create_user_command("CopyFiles", function(opts)
    M.copy_files_cmd(opts)
  end, { nargs = "+" })
  vim.api.nvim_create_user_command("CopyOpenBuffers", function(opts)
    M.copy_open_buffers(opts)
  end, {
    nargs = "?", -- optional "modified"
    bang = true, -- :CopyOpenBuffers! includes unlisted
    complete = function(_, _, _)
      return { "modified" } -- simple completion
    end,
  })
end

return M
