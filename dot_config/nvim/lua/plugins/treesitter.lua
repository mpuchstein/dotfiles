-- nvim-treesitter dropped: archived, incompatible with Neovim 0.12 API.
-- Neovim 0.12 handles treesitter natively (highlighting, folding, injections).
-- Bundled parsers: bash, c, lua, markdown, markdown_inline, python, query,
--                  regex, vim, vimdoc.
-- Additional parsers (rust, ts, java, etc.): install via AUR tree-sitter-* or
-- tree-sitter-cli: https://github.com/tree-sitter/tree-sitter

return {
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
