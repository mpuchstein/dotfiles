-- Gilles Castel-style LaTeX snippets for LuaSnip
return {
  -- Make sure autosnippets are enabled globally
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, _) require("luasnip").config.setup { enable_autosnippets = true } end,
  },

  -- The LaTeX snippets themselves
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    ft = { "tex", "plaintex", "markdown" },
    dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    opts = { use_treesitter = false, allow_on_markdown = true }, -- use vimtex to detect math mode
    config = function(_, opts) require("luasnip-latex-snippets").setup(opts) end,
  },
}
