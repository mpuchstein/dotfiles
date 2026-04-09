local M = {}

local function setup()
  local dap = require("dap")
  local mason_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"

  dap.adapters["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "node",
      args = { mason_path .. "/js-debug/src/dapDebugServer.js", "${port}" },
    },
  }

  local js_config = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }

  for _, lang in ipairs({ "javascript", "typescript", "svelte" }) do
    dap.configurations[lang] = js_config
  end
end

setup()
return M
