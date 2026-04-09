local augroup = function(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Filetype detection
vim.filetype.add({ extension = { j2 = "jinja.html" } })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("trailing_whitespace"),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Resize splits when window resizes
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Close certain filetypes with q
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "lspinfo", "man", "qf", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- LSP on attach: inlay hints + navic
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("lsp_attach"),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    -- Enable inlay hints
    if client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    -- Wire nvim-navic for breadcrumbs (lualine winbar)
    if client.supports_method("textDocument/documentSymbol") then
      local ok, navic = pcall(require, "nvim-navic")
      if ok then
        navic.attach(client, args.buf)
      end
    end

    -- LSP keymaps (buffer-local)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
    end

    map("gd", vim.lsp.buf.definition,      "Go to definition")
    map("gi", vim.lsp.buf.implementation,  "Go to implementation")
    map("<leader>D", vim.lsp.buf.type_definition, "Type definition")
    map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
    map("<leader>lr", vim.lsp.buf.rename,  "Rename symbol")
    map("<leader>ls", vim.lsp.buf.document_symbol, "Document symbols")
    map("<leader>lR", vim.lsp.buf.references, "References")
    map("<leader>li", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
    end, "Toggle inlay hints")

    -- grr, grn, gra, K are Neovim 0.12 built-ins, no need to set
  end,
})
