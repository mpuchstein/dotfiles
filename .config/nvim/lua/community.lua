-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.colorscheme.catppuccin" },
  -- these packs can set up things such as Treesitter, Language Servers, additional language specific plugins, and more!
  { import = "astrocommunity.snippet.nvim-snippets" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.hyprlang" },
  { import = "astrocommunity.pack.java" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.sql" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.xml" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.kotlin" },
  { import = "astrocommunity.pack.php" },

  { import = "astrocommunity.markdown-and-latex.vimtex" },
  { import = "astrocommunity.completion.cmp-latex-symbols" },

  { import = "astrocommunity.keybinding.nvcheatsheet-nvim" },
  -- import/override with your plugins folder
}
