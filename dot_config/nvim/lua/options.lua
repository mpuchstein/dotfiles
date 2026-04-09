local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Editing
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.virtualedit = "block"
opt.clipboard = "unnamedplus"

-- Files
opt.undofile = true
opt.swapfile = false
opt.backup = false

-- Windows
opt.splitright = true
opt.splitbelow = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Appearance
opt.termguicolors = true
opt.cursorline = true
opt.showmode = false        -- lualine handles this
opt.pumheight = 10
opt.conceallevel = 2        -- for LaTeX/Markdown

-- Folds (treesitter-based, foldenable=false = open all by default)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false
opt.foldlevel = 99

-- Spell (disabled globally; enabled per-filetype via ftplugin/)
opt.spell = false

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Misc
opt.mouse = "a"
opt.fileencoding = "utf-8"
opt.shortmess:append("c")
