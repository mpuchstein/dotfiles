-- Ensure Treesitter knows about LaTeX (nabla benefits, and some plugins use it)
return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    if type(opts.ensure_installed) == "table" then
      if not vim.tbl_contains(opts.ensure_installed, "latex") then table.insert(opts.ensure_installed, "latex") end
    end
  end,
}
