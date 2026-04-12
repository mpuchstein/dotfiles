local map = vim.keymap.set

-- Better window navigation
map("n", "<leader>|", "<C-w>v", { desc = "Vertical split" })
map("n", "<leader>-", "<C-w>s", { desc = "Horizontal split" })
map("n", "<leader>w", "<C-w>q", { desc = "Close split" })

-- Buffer navigation
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<cr>", { desc = "Close other buffers" })

-- Diagnostics
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

-- Move lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Don't yank on paste in visual mode
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Save
map({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "Save" })

-- Quit
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all" })

-- Tab navigation
map("n", "<A-Tab>",   "<cmd>tabnext<cr>",     { desc = "Next tab" })
map("n", "<A-S-Tab>", "<cmd>tabprevious<cr>", { desc = "Prev tab" })
