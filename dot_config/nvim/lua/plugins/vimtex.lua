return {
  -- VimTeX: LaTeX compilation, navigation, text objects
  {
    "lervag/vimtex",
    ft = { "tex", "plaintex", "bib" },
    init = function()
      -- Must be set before vimtex loads
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-pdf",
          "-shell-escape",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
          "-lualatex",
        },
      }
      -- Disable vimtex completion (blink.cmp handles it via cmp-vimtex)
      vim.g.vimtex_complete_enabled = 0
      -- Disable vimtex's own syntax (use treesitter instead, with vim regex fallback)
      vim.g.vimtex_syntax_enabled = 1
      vim.g.vimtex_syntax_conceal_disable = 0
    end,
  },
}
