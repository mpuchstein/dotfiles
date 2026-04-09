return {
  -- Auto-close brackets, with LaTeX math guard
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      npairs.setup({
        check_ts = true,
        ts_config = { java = false }, -- disable for Java (interferes with jdtls)
        fast_wrap = { map = "<M-e>" },
      })

      -- LaTeX inline math: $...$ pair
      npairs.add_rules({
        Rule("$", "$", { "tex", "latex" })
          :with_pair(cond.not_after_regex("%%"))   -- don't pair after %
          :with_move(cond.none())
          :with_del(cond.not_after_regex("xx"))
          :with_cr(cond.none()),
      })
    end,
  },

  -- Surround operations: ys, cs, ds
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Formatter (format on save)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>lf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format" },
    },
    opts = {
      formatters_by_ft = {
        lua             = { "stylua" },
        rust            = { "rustfmt" },
        javascript      = { "prettier" },
        typescript      = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte          = { "prettier" },
        java            = { "google-java-format" },
        json            = { "prettier" },
        yaml            = { "prettier" },
        toml            = { "taplo" },
        html            = { "prettier" },
        css             = { "prettier" },
        markdown        = { "prettier" },
        ["jinja.html"]  = { "djlint" },
      },
      format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = true,
      },
    },
  },
}
