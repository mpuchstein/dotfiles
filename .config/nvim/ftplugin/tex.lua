-- Spell-check (tweak languages to your needs)
vim.opt_local.spell = true
vim.opt_local.spelllang = { "en_gb", "de_de", "fr" }

-- Niceties for prose/math
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.textwidth = 0 -- don't hard-wrap LaTeX
