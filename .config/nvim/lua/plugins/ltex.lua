-- Grammar & spell checking for LaTeX/Markdown via LanguageTool (LTeX-LS)
return {
  -- Tell AstroLSP to manage the ltex server and pass our settings
  {
    "AstroNvim/astrolsp",
    ---@param opts AstroLSPOpts
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      if not vim.tbl_contains(opts.servers, "ltex") then table.insert(opts.servers, "ltex") end

      -- Extend the ltex server configuration
      opts.config = require("astrocore").extend_tbl(opts.config or {}, {
        ltex = {
          filetypes = { "tex", "plaintex", "bib", "markdown" },
          settings = {
            ltex = {
              -- Run checks on save for performance; switch to "edit" if you prefer live feedback
              checkFrequency = "save",
              -- Pick the language you want LTeX to check as the document language
              language = "en-GB",
              -- Mother tongue helps the grammar engine (adjust to your preference)
              additionalRules = { motherTongue = "de-DE" },
              -- Let ltex_extra manage dictionaries/rules on disk
              dictionary = {
                ["en-GB"] = {},
                ["de-DE"] = {},
                ["fr-FR"] = {},
              },
              disabledRules = {
                ["en-GB"] = {},
                ["de-DE"] = {},
                ["fr-FR"] = {},
              },
              hiddenFalsePositives = {
                ["en-GB"] = {},
                ["de-DE"] = {},
                ["fr-FR"] = {},
              },
            },
          },
          -- hook up ltex_extra when the server attaches
          on_attach = function(client, bufnr)
            local ok, ltex_extra = pcall(require, "ltex_extra")
            if ok then
              ltex_extra.setup {
                -- load both EN+DE dictionaries; change to your set
                load_langs = { "en-GB", "de-DE", "fr-FR" },
                init_check = true,
                -- store per-project files in .ltex (add to .gitignore if you want)
                path = ".ltex",
                log_level = "none",
              }
            end
          end,
        },
      })
    end,
  },

  -- Companion plugin: add-to-dictionary / disable-rule / hide-false-positive
  {
    "barreiroleo/ltex_extra.nvim",
    ft = { "tex", "plaintex", "markdown" },
    lazy = true,
  },
}
