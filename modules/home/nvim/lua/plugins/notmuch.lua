-- notmuch.nvim, on trial as an aerc replacement: reads the same notmuch database
-- that lieer fills (modules/home/mail.nix). Sending is not set up yet: the plugin
-- always runs `msmtp -t`, which would need a shim handing the mail to `gmi send -t`.

-- The saved searches aerc shows as folders, read from its queries.conf so the two
-- stay the same; listed in aerc's folders-sort order.
local function aerc_queries()
  local path = vim.fn.expand("~/.config/aerc/queries.conf")
  if vim.fn.filereadable(path) == 0 then
    return {}
  end
  local q = {}
  for line in io.lines(path) do
    local name, query = line:match("^([^=#]+)=(.+)$")
    if name then
      q[vim.trim(name)] = vim.trim(query)
    end
  end
  local order = { "INBOX", "focus", "todo", "leads", "review-v2", "alerts", "automated", "Sent", "Drafts", "Starred" }
  local queries = {}
  for _, name in ipairs(order) do
    if q[name] then
      table.insert(queries, { name = name, query = q[name] })
    end
  end
  return queries
end

return {
  "yousefakbar/notmuch.nvim",
  cmd = { "Notmuch", "NmSearch", "Inbox" },
  keys = {
    { "<leader>m", "<Cmd>Notmuch<CR>", desc = "Mail (notmuch)" },
  },
  opts = function()
    return {
      -- `%` syncs through the same service the timer runs (logged, and on
      -- asusprime followed by triage); the plugin appends `; notmuch new`, which
      -- finds nothing since lieer indexes what it fetches.
      maildir_sync_cmd = "systemctl --user start lieer-valolink.service",
      sync = { sync_mode = "background" },
      render_html_body = true, -- via w3m
      thread_view_mode = "newest-first",
      thread_auto_expand = "first",
      queries = aerc_queries(),
    }
  end,
  config = function(_, opts)
    -- The plugin loads libnotmuch with ffi.load("notmuch"), which NixOS's loader
    -- path doesn't have; it sits next to the notmuch binary in the store.
    local ffi = require("ffi")
    local load = ffi.load
    local bin = vim.uv.fs_realpath(vim.fn.exepath("notmuch"))
    if bin then
      local lib = vim.fs.normalize(vim.fs.dirname(bin) .. "/../lib/libnotmuch.so")
      ffi.load = function(name, ...)
        return load(name == "notmuch" and lib or name, ...)
      end
    end
    require("notmuch").setup(opts)

    -- Colours from the terminal palette (modules/home/terminal-palette.nix), as
    -- in aerc: read mail has a grey date and blue sender; unread mail is bold
    -- with an aqua date and pink sender. Red and orange stay out of the list.
    local palette = { grey = "#928374", blue = "#7daea3", aqua = "#89b482", pink = "#d3869b" }
    local function set_hl()
      vim.api.nvim_set_hl(0, "NotmuchSearchDate", { fg = palette.grey })
      vim.api.nvim_set_hl(0, "NotmuchSearchAuthors", { fg = palette.blue })
      vim.api.nvim_set_hl(0, "NotmuchSearchTags", { fg = palette.aqua })
      vim.api.nvim_set_hl(0, "NotmuchSearchUnread", { bold = true })
      vim.api.nvim_set_hl(0, "NotmuchSearchUnreadDate", { fg = palette.aqua, bold = true })
      vim.api.nvim_set_hl(0, "NotmuchSearchUnreadAuthors", { fg = palette.pink, bold = true })
    end
    set_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

    -- The plugin only lists `unread` among the tags, which are usually cut off.
    -- Unread rows are restyled at every redraw, so tagging shows at once: the row
    -- goes bold and the plugin's date and author spans get the unread colours.
    local search = require("notmuch.search")
    local plugin_ns = require("notmuch.search.highlights").namespace
    local ns = vim.api.nvim_create_namespace("notmuch_unread")
    local unread_groups = {
      NotmuchSearchDate = "NotmuchSearchUnreadDate",
      NotmuchSearchAuthors = "NotmuchSearchUnreadAuthors",
    }
    vim.api.nvim_set_decoration_provider(ns, {
      on_win = function(_, _, buf)
        return vim.bo[buf].filetype == "notmuch-threads"
      end,
      on_line = function(_, _, buf, row)
        local record = search.get_record(buf, row + 1)
        if not (record and vim.tbl_contains(record.tags, "unread")) then
          return
        end
        vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
          end_row = row + 1,
          hl_group = "NotmuchSearchUnread",
          ephemeral = true,
          priority = 5000,
        })
        local spans = vim.api.nvim_buf_get_extmarks(buf, plugin_ns, { row, 0 }, { row, -1 }, { details = true })
        for _, mark in ipairs(spans) do
          local group = unread_groups[mark[4].hl_group]
          if group then
            vim.api.nvim_buf_set_extmark(buf, ns, row, mark[3], {
              end_col = mark[4].end_col,
              hl_group = group,
              ephemeral = true,
              priority = 5010,
            })
          end
        end
      end,
    })

    -- After a tag change the plugin redraws the whole list, which takes seconds
    -- on INBOX (67k threads). The tag write itself is a few ms, so only the
    -- changed rows are re-rendered instead; anything else falls back to a full draw.
    local render = require("notmuch.search.render")
    local function redraw_rows(buf, records)
      local state = search.get_state(buf)
      if not (state and state.widths and state.id_to_row) then
        return false
      end
      for _, record in ipairs(records) do
        if not state.id_to_row[record.thread] then
          return false
        end
      end
      local opts = require("notmuch.config").options.search
      vim.bo[buf].modifiable = true
      for _, record in ipairs(records) do
        local row = state.id_to_row[record.thread] - 1
        local result = render.render({ record }, opts, state.width, state.widths, false)
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, result.lines)
        vim.api.nvim_buf_clear_namespace(buf, plugin_ns, row, row + 1)
        for _, span in ipairs(result.highlights) do
          vim.api.nvim_buf_set_extmark(buf, plugin_ns, row, span.start_col, {
            end_col = span.end_col,
            hl_group = span.group,
          })
        end
      end
      vim.bo[buf].modifiable = false
      return true
    end
    -- The notmuch database's revision goes up with every write, by lieer, the
    -- triage or anything else; the live update below reloads when it moves.
    local function revision(callback)
      vim.system({ "notmuch", "count", "--lastmod", "id:none" }, { text = true }, function(res)
        local rev = res.code == 0 and tonumber((res.stdout or ""):match("(%d+)%s*$"))
        if rev then
          vim.schedule(function()
            callback(rev)
          end)
        end
      end)
    end
    local seen_revision

    local tag = require("notmuch.tag")
    for _, name in ipairs({ "thread_add_tag", "thread_rm_tag", "thread_toggle_tag" }) do
      local apply = tag[name]
      tag[name] = function(tags, first, last)
        local records = search.selected(0, first, last)
        local draw = search.draw
        search.draw = function(buf, ...)
          if select("#", ...) == 0 and redraw_rows(buf, records) then
            return
          end
          return draw(buf, ...)
        end
        local ok, err = pcall(apply, tags, first, last)
        search.draw = draw
        if not ok then
          error(err, 0)
        end
        -- Own tag changes don't count as news: a thread marked read stays in
        -- view until something else changes the database.
        revision(function(rev)
          seen_revision = rev
        end)
      end
    end

    -- Run the search again from an empty list: the plugin's own refresh first
    -- redraws every old row, which freezes on big lists.
    local function reload(buf, query)
      local state = search.get_state(buf)
      if not state then
        return
      end
      if query then
        state.query = query
        pcall(vim.api.nvim_buf_set_name, buf, "notmuch-search: " .. query)
      end
      state.loaded = false
      search.refresh(buf)
    end
    -- `u` narrows the list to unread threads and back.
    local function toggle_unread(buf)
      local state = search.get_state(buf)
      if state then
        local all = state.query:match("^%((.*)%) and tag:unread$")
        reload(buf, all or ("(" .. state.query .. ") and tag:unread"))
      end
    end

    -- Live update: every 15 s, if the database changed, refresh the searches on
    -- screen. The plugin's refresh keeps the old list up until the new one is in
    -- and keeps the cursor on its thread; only its opening full redraw (seconds
    -- on INBOX) is skipped.
    local function refresh_in_place(buf)
      local draw = search.draw
      search.draw = function() end
      pcall(search.refresh, buf)
      search.draw = draw
    end
    local function visible_searches()
      local bufs = {}
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local state = vim.bo[buf].filetype == "notmuch-threads" and search.get_state(buf)
        if state and state.loaded and not state.process then
          bufs[buf] = true
        end
      end
      return bufs
    end
    local timer = vim.uv.new_timer()
    timer:start(15000, 15000, function()
      vim.schedule(function()
        if vim.tbl_isempty(visible_searches()) then
          return
        end
        revision(function(rev)
          if seen_revision and rev ~= seen_revision then
            for buf in pairs(visible_searches()) do
              refresh_in_place(buf)
            end
          end
          seen_revision = rev
        end)
      end)
    end)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "notmuch-threads",
      group = vim.api.nvim_create_augroup("notmuch_lieer", { clear = true }),
      callback = function(ev)
        -- A search that opens now is current; later changes are news.
        revision(function(rev)
          seen_revision = rev
        end)
        vim.keymap.set("n", "u", function()
          toggle_unread(ev.buf)
        end, { buffer = ev.buf, desc = "Toggle unread only" })
        vim.keymap.set("n", "r", function()
          reload(ev.buf)
        end, { buffer = ev.buf, desc = "Refresh search" })
        -- `D` deletes the files of every tag:del mail from disk; lieer owns those
        -- files and Gmail would keep the mail. `dd` tags `del`, which lieer would
        -- push as a Gmail label; move to Gmail's trash instead.
        pcall(vim.keymap.del, "n", "D", { buffer = ev.buf })
        vim.keymap.set("n", "dd", "<Cmd>TagAdd trash<CR><Cmd>TagRm inbox<CR>j", { buffer = ev.buf })
        vim.keymap.set("x", "d", ":TagAdd trash<CR>gv:TagRm inbox<CR>", { buffer = ev.buf })
      end,
    })
  end,
}
