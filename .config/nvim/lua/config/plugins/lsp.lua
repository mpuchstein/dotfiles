-- lsp.lua
-- Connect Mason with lspconfig
require("mason-lspconfig").setup({
  -- Automatically install these servers
  ensure_installed = {
    "lua_ls",                 -- Lua
    "pyright",                -- Python
    "biome",                  -- TypeScript/JavaScript
    "rust_analyzer",          -- Rust
    "gopls",                  -- Go
    "clangd",                 -- C/C++
    "bashls",                 -- Bash
    "emmet_language_server",  -- Emmet
    "somesass_ls",            -- SASS
    "hyprls",                 -- Hyprlang
  },
  automatic_installation = true,
})

-- Set up LSP capabilities (used by completion)
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- Check if nvim-cmp is available to enhance capabilities
local has_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if has_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Function to set up all installed LSP servers
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Key mappings
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>lf', function() vim.lsp.buf.format { async = true } end, bufopts)

  -- Log a message when a server attaches
  print(string.format("LSP server '%s' attached to this buffer", client.name))
end

-- Set up all servers installed via Mason
require("mason-lspconfig").setup_handlers {
  -- Default handler for installed servers
  function(server_name)
    require('lspconfig')[server_name].setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end,

  -- Special configurations for specific servers
  ["lua_ls"] = function()
    require('lspconfig').lua_ls.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = { globals = {'vim'} },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    }
  end,
}

-- Configure diagnostic display
vim.diagnostic.config({
  virtual_text = {
    prefix = '●', -- Could be '■', '▎', 'x'
    source = "if_many",
  },
  float = {
    source = "always",
    border = "rounded",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Change diagnostic symbols in the sign column
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
