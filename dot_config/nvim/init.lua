-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader must be set before lazy loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core config (order matters)
require("options")
require("autocmds")

-- Load LSP server configurations (vim.lsp.config calls)
-- These must run before vim.lsp.enable() in plugins/lsp.lua
do
  local lsp_dir = vim.fn.stdpath("config") .. "/lua/lsp"
  for _, name in ipairs(vim.fn.readdir(lsp_dir)) do
    if name:match("%.lua$") then
      require("lsp." .. name:gsub("%.lua$", ""))
    end
  end
end

-- Load colorscheme before plugins (prevents flash of wrong colors)
-- colors/apex-neon.lua is managed by refresh-apex-themes, not via lazy
vim.cmd.colorscheme("apex-neon")

-- Setup lazy.nvim
require("lazy").setup({
  spec = { { import = "plugins" } },
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
  defaults = { lazy = false },
  install = { colorscheme = { "apex-neon", "habamax" } },
  checker = { enabled = false },
  change_detection = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- Keymaps loaded after lazy so plugin keymaps can be set in their own files
require("keymaps")
