return {
  -- Floating terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm direction=float<cr>", mode = { "n", "t" }, desc = "Toggle float terminal" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = nil, -- managed via keymaps above
      hide_numbers = true,
      shade_terminals = false,
      start_in_insert = true,
      insert_mappings = false,
      terminal_mappings = false,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      float_opts = {
        border = "curved",
        winblend = 3,
      },
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
      end,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- Named terminals
      local Terminal = require("toggleterm.terminal").Terminal

      -- Tauri dev server
      local tauri_term = Terminal:new({
        cmd = "cargo tauri dev",
        direction = "float",
        hidden = true,
        display_name = "Tauri Dev",
      })

      -- Test runner
      local test_term = Terminal:new({
        direction = "horizontal",
        hidden = true,
        display_name = "Tests",
      })

      -- Claude Code
      local claude_term = Terminal:new({
        cmd = "claude",
        direction = "float",
        hidden = true,
        display_name = "Claude Code",
        float_opts = { border = "curved" },
      })

      vim.keymap.set("n", "<leader>tt", function() tauri_term:toggle() end, { desc = "Toggle Tauri dev" })
      vim.keymap.set("n", "<leader>te", function() test_term:toggle() end,  { desc = "Toggle test terminal" })
      vim.keymap.set("n", "<leader>cc", function() claude_term:toggle() end, { desc = "Claude Code" })
    end,
  },
}
