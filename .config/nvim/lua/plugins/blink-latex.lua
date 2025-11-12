return {
  -- Let blink.cmp consume nvim-cmp sources
  { "saghen/blink.compat", version = "2.*", lazy = true, opts = {} },

  -- Add vimtex + latex symbol sources to blink.cmp
  {
    "Saghen/blink.cmp",
    optional = true,
    dependencies = {
      "micangl/cmp-vimtex", -- environments, \cite, \ref, etc. via vimtex
      "kdheepak/cmp-latex-symbols", -- math symbols via LaTeX macros
    },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }

      -- Only turn on the LaTeX sources for TeX filetypes
      opts.sources.per_filetype = vim.tbl_deep_extend("force", opts.sources.per_filetype or {}, {
        tex = { inherit_defaults = true, "vimtex", "latex_symbols" },
        plaintex = { inherit_defaults = true, "vimtex", "latex_symbols" },
      })

      -- Expose nvim-cmp sources to blink via blink.compat
      opts.sources.providers.vimtex = {
        name = "vimtex",
        module = "blink.compat.source",
      }
      opts.sources.providers.latex_symbols = {
        name = "latex_symbols",
        module = "blink.compat.source",
        -- Insert LaTeX commands (e.g. \alpha) instead of Unicode characters:
        opts = { strategy = 2 }, -- documented in cmp-latex-symbols README
        score_offset = -2, -- keep it below LSP/snippets in relevance
      }
      return opts
    end,
  },
}
