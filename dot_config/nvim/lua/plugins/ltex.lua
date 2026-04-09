return {
  -- ltex_extra: persist custom dictionary/rules to disk
  {
    "barreiroleo/ltex_extra.nvim",
    ft = { "tex", "plaintex", "bib", "markdown" },
    lazy = true,
    -- Actual setup happens in lua/lsp/ltex.lua on_attach
  },
}
