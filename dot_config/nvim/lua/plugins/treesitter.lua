-- Neovim 0.12 handles treesitter natively. tree-sitter-manager provides
-- parser installation (replaces archived nvim-treesitter). Requires:
--   tree-sitter CLI, git, gcc/clang (system-wide)

return {
  {
    "romus204/tree-sitter-manager.nvim",
    cmd = "TSManager",
    opts = {
      ensure_installed = {
        "rust", "typescript", "javascript", "svelte",
        "java", "latex", "yaml", "toml", "html", "css",
        "jinja", "json",
      },
    },
  },


  -- Textobjects: pairs, quotes, args, brackets — no treesitter dependency
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = {
      n_lines = 500,
      -- Extend the default textobjects with mini.extra
      -- a( i( a[ i[ a{ i{ a< i< a" i" a' i' a` i` — built-in
      -- af if — function call args (built-in)
    },
  },
}
