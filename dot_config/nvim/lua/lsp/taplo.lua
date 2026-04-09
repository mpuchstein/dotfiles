vim.lsp.config("taplo", {
  settings = {
    evenBetterToml = {
      formatter = {
        indentTables = false,
        indentEntries = false,
        inlineTable = {},
        trailingNewline = true,
        reorderKeys = false,
      },
    },
  },
})
