return {
  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      enable_autosnippets = true,
      history = true,
      update_events = "TextChanged,TextChangedI",
    },
    config = function(_, opts)
      require("luasnip").setup(opts)
      require("luasnip.loaders.from_vscode").lazy_load()
      -- Extend js snippets to ts
      require("luasnip").filetype_extend("typescript", { "javascript" })
      require("luasnip").filetype_extend("svelte", { "javascript", "html" })
    end,
  },

  -- Castel-style LaTeX snippets (autosnippets for math mode)
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    ft = { "tex", "plaintex", "markdown" },
    dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    opts = { use_treesitter = false, allow_on_markdown = true },
    config = function(_, opts)
      require("luasnip-latex-snippets").setup(opts)
    end,
  },

  -- blink.compat: exposes nvim-cmp sources to blink.cmp
  { "saghen/blink.compat", version = "2.*", lazy = true, opts = {} },

  -- LaTeX completion sources (via blink.compat)
  {
    "micangl/cmp-vimtex",
    lazy = true,
  },
  {
    "kdheepak/cmp-latex-symbols",
    lazy = true,
  },

  -- Main completion engine
  {
    "saghen/blink.cmp",
    version = "v0.*",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saghen/blink.compat",
      "micangl/cmp-vimtex",
      "kdheepak/cmp-latex-symbols",
    },
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      completion = {
        ghost_text = { enabled = true },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },
      },
      snippets = {
        preset = "luasnip",
      },
      sources = {
        default = { "lsp", "snippets", "buffer", "path" },
        per_filetype = {
          tex = { inherit_defaults = true, "vimtex", "latex_symbols" },
          plaintex = { inherit_defaults = true, "vimtex", "latex_symbols" },
        },
        providers = {
          vimtex = {
            name = "vimtex",
            module = "blink.compat.source",
          },
          latex_symbols = {
            name = "latex_symbols",
            module = "blink.compat.source",
            opts = { strategy = 2 }, -- insert LaTeX commands, not Unicode
            score_offset = -2,
          },
        },
      },
      signature = { enabled = true },
    },
  },
}
