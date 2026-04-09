return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",           desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",            desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",              desc = "Buffers" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "LSP symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",          desc = "Diagnostics" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",             desc = "Recent files" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>",          desc = "Grep word under cursor" },
      { "<leader>fp", "<cmd>Telescope projects<cr>",             desc = "Projects" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",            desc = "Help tags" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "smart" },
          file_ignore_patterns = { ".git/", "node_modules/", "target/" },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "projects")
    end,
  },
}
