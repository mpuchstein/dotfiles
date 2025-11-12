-- Minimal Markdown + math workflow (FOSS/KISS):
-- - Blink completion of LaTeX symbols in Markdown
-- - :MdPdf to compile current .md -> PDF via Pandoc (LuaLaTeX) and open in Zathura
-- - Ensure Treesitter grammars for markdown

return {
  -- Extend blink.cmp sources so Markdown gets LaTeX symbol completion (inserts \alpha, not α)
  {
    "Saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.per_filetype = vim.tbl_deep_extend("force", opts.sources.per_filetype or {}, {
        markdown = { inherit_defaults = true, "latex_symbols" },
      })
      return opts
    end,
  },

  -- Ensure Treesitter grammars for better Markdown editing
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, lang in ipairs { "markdown", "markdown_inline" } do
        if not vim.tbl_contains(opts.ensure_installed, lang) then table.insert(opts.ensure_installed, lang) end
      end
    end,
  },

  -- Add a simple :MdPdf command and a keymap
  {
    "AstroNvim/astrocore",
    opts = {
      commands = {
        MdPdf = {
          function()
            local stem = vim.fn.expand "%:r"
            local ext = vim.fn.expand "%:e"
            if ext ~= "md" then
              vim.notify("MdPdf: open a Markdown file (*.md)", vim.log.levels.WARN)
              return
            end
            local cmd = {
              "pandoc",
              stem .. ".md",
              "-o",
              stem .. ".pdf",
              "--from=markdown+tex_math_dollars+raw_tex",
              "--pdf-engine=lualatex",
              "--citeproc",
            }
            vim.fn.jobstart(cmd, {
              detach = true,
              on_exit = function()
                -- Open Zathura only once per session; it will auto-reload on subsequent builds
                if not vim.g._mdpdf_zathura_opened then
                  vim.g._mdpdf_zathura_opened = true
                  vim.fn.jobstart({ "zathura", "--fork", stem .. ".pdf" }, { detach = true })
                end
              end,
            })
          end,
          desc = "Pandoc → PDF (LuaLaTeX) and open in Zathura",
        },
      },
      mappings = {
        n = {
          ["<leader>mp"] = { "<cmd>MdPdf<cr>", desc = "Markdown → PDF (Pandoc)" },
        },
      },
    },
  },
}
