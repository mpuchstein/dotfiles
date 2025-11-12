-- Spell-check (tweak languages to your needs)
vim.opt_local.spell = true
vim.opt_local.spelllang = { "en_us", "de_de" }

-- Niceties for prose/math
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2 -- vimtex has sensible conceal defaults
vim.opt_local.textwidth = 0 -- don't hard-wrap LaTeX
