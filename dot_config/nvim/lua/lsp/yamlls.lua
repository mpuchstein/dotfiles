vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      keyOrdering = false,
      format = { enable = true },
      validate = true,
      schemaStore = { enable = false, url = "" },
      schemas = {},
    },
  },
})
