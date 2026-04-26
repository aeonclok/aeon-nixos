return {
  "David-Kunz/gen.nvim",
  cmd = "Gen",
  keys = {
    -- The only keymap you need. Works in Normal and Visual mode.
    { "<leader>ag", ":Gen<CR>", mode = { "n", "v" }, desc = "Ollama Gen" },
  },
  opts = {
    model = "qwen2.5-coder:7b-instruct-q4_0", -- Your exact local model
    host = "127.0.0.1",
    port = "11434",
    display_mode = "split", -- Outputs the code into a clean vertical split
    show_prompt = true,
    show_model = true,
    quit_map = "q", -- Press 'q' to quickly close the AI window
    retry_map = "<c-r>", -- Press Ctrl+r to make it try again

    -- gen.nvim lets you define custom prompts easily!
  },
}
