return {
  "lervag/vimtex",
  lazy = false, -- load immediately (recommended by astrocommunity)
  init = function()
    -- Viewer
    vim.g.vimtex_view_method = "zathura"

    -- Compiler: latexmk + LuaLaTeX
    vim.g.vimtex_compiler_method = "latexmk"
    -- Option A: pass -lualatex explicitly to latexmk
    vim.g.vimtex_compiler_latexmk = {
      options = {
        "-lualatex",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-file-line-error",
        -- remove if you don't need shell-escape:
        "-shell-escape",
      },
    }
    -- Option B (also helpful): make LuaLaTeX the default engine for latexmk
    vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
  end,
}
