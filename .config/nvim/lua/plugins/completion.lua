-- Autocompletion system
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
    "hrsh7th/cmp-buffer",   -- Buffer source
    "hrsh7th/cmp-path",     -- Path source
    "L3MON4D3/LuaSnip",     -- Snippet engine
    "saadparwaiz1/cmp_luasnip", -- Snippet source
  },
}
