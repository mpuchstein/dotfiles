-- Treesitter for syntax highlighting (load early)
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    priority = 100, -- Load early
  }
