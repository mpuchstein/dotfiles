-- whichkey.lua
-- Check if which-key is available
local has_which_key, which_key = pcall(require, "which-key")
if not has_which_key then
  print("Warning: which-key not found. Key binding help won't be available.")
  return
end

-- Set up which-key with error handling
local setup_ok, _ = pcall(which_key.setup, {
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = true,
      suggestions = 20,
    },
    presets = {
      operators = true,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
  window = {
    border = "rounded",
    padding = { 2, 2, 2, 2 },
  },
  layout = {
    height = { min = 4, max = 25 },
    width = { min = 20, max = 50 },
  },
  ignore_missing = false,
})

if not setup_ok then
  print("Error setting up which-key. Key binding help won't work correctly.")
  return
end

-- Register key bindings with which-key
local register_ok, _ = pcall(which_key.register, {
  f = {
    name = "File", -- Optional group name
    f = { "<cmd>Telescope find_files<cr>", "Find File" },
    r = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
    g = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
    b = { "<cmd>Telescope buffers<cr>", "Buffers" },
    n = { "<cmd>enew<cr>", "New File" },
  },
  e = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
  l = {
    name = "LSP",
    d = { "<cmd>Telescope lsp_definitions<cr>", "Definitions" },
    r = { "<cmd>Telescope lsp_references<cr>", "References" },
    a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
    f = { "<cmd>lua vim.lsp.buf.format()<cr>", "Format" },
    h = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover" },
    R = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
  },
  b = {
    name = "Buffer",
    n = { "<cmd>bnext<cr>", "Next Buffer" },
    p = { "<cmd>bprevious<cr>", "Previous Buffer" },
    d = { "<cmd>bdelete<cr>", "Delete Buffer" },
  },
}, { prefix = "<leader>" })

if not register_ok then
  print("Error registering which-key bindings.")
  return
end

print("Key binding help initialized!")

