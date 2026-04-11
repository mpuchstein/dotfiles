return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "rouge8/neotest-rust",
      "rcasia/neotest-java",
      "marilari88/neotest-vitest",
    },
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end,                           desc = "Run nearest test"  },
      { "<leader>ts", function() require("neotest").run.run(vim.fn.expand("%")) end,         desc = "Run test suite"    },
      { "<leader>tl", function() require("neotest").run.run_last() end,                      desc = "Run last test"     },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end,       desc = "Open test output"  },
      { "<leader>tp", function() require("neotest").output_panel.toggle() end,               desc = "Toggle test panel" },
      { "<leader>ts", function() require("neotest").summary.toggle() end,                    desc = "Toggle summary"    },
    },
    opts = function()
      return {
        adapters = {
          require("neotest-rust")({ args = { "--no-capture" } }),
          require("neotest-java")({ ignore_wrapper = false }),
          require("neotest-vitest"),
        },
        output = { open_on_run = false },
        quickfix = { open = false },
        status = { virtual_text = true },
      }
    end,
  },
}
