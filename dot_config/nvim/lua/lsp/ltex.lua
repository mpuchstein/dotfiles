-- LTeX grammar/spell checking for LaTeX and Markdown
-- ltex_extra.nvim manages dictionaries/rules persistence
vim.lsp.config("ltex", {
  filetypes = { "tex", "plaintex", "bib", "markdown" },
  settings = {
    ltex = {
      checkFrequency = "save",
      language = "en-GB",
      additionalRules = { motherTongue = "de-DE" },
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
  on_attach = function(client, bufnr)
    local ok, ltex_extra = pcall(require, "ltex_extra")
    if ok then
      ltex_extra.setup({
        load_langs = { "en-GB", "de-DE", "fr-FR" },
        init_check = true,
        path = ".ltex",
        log_level = "none",
      })
    end
  end,
})
