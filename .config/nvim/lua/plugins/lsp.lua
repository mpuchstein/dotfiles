-- Language Server Protocol support
return {
    "neovim/nvim-lspconfig", -- Base LSP configurations
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    }
}
