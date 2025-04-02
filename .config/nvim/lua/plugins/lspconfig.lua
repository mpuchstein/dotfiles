-- Language Server Protocol support
return {
    "neovim/nvim-lspconfig", -- Base LSP configurations
    dependencies = {
      -- Server installation manager
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  }
