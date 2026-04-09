local M = {}

local function setup()
  local dap = require("dap")
  local mason_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb"

  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = mason_path .. "/extension/adapter/codelldb",
      args = { "--port", "${port}" },
    },
  }

  dap.configurations.rust = {
    {
      name = "Launch (Rust)",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
    },
    {
      name = "Launch Tauri (Rust)",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/src-tauri/target/debug/", "file")
      end,
      cwd = "${workspaceFolder}/src-tauri",
      stopOnEntry = false,
      args = {},
    },
  }
end

setup()
return M
