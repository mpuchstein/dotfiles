return {
  -- Local AI ghost text via ollama (FIM completion)
  {
    "huggingface/llm.nvim",
    event = "InsertEnter",
    keys = {
      { "<leader>ta", "<cmd>LLMToggleAutoSuggest<cr>", desc = "Toggle AI suggestions" },
    },
    opts = {
      backend = "ollama",
      model = "qwen2.5-coder:latest",
      url = vim.env.OLLAMA_HOST or "http://localhost:11434",
      tokens_to_clear = { "<|endoftext|>" },
      fim = {
        enabled = true,
        prefix = "<|fim_prefix|>",
        middle = "<|fim_middle|>",
        suffix = "<|fim_suffix|>",
      },
      context_window = 4096,
      tokenizer = nil, -- use token estimation
      enable_suggestions_on_startup = true,
      display = {
        renderer = "virtual-text",
        virtual_text = {
          enabled = true,
          hl = "Comment",
        },
      },
      accept_keymap = "<Tab>",
      dismiss_keymap = "<C-]>",
    },
  },
}
