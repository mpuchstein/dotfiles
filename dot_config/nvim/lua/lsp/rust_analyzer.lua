vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        runBuildScripts = true,
      },
      checkOnSave = {
        allFeatures = true,
        command = "clippy",
        extraArgs = { "--no-deps" },
      },
      procMacro = {
        enable = true,
        ignored = {
          ["async-trait"] = { "async_trait" },
          ["napi-derive"] = { "napi" },
          ["async-recursion"] = { "async_recursion" },
        },
      },
      inlayHints = {
        bindingModeHints = { enable = false },
        closingBraceHints = { minLines = 25 },
        lifetimeElisionHints = { enable = "never" },
        typeHints = { enable = true },
      },
    },
  },
})

-- Support project-local override (e.g. Tauri: root_dir = src-tauri/)
local local_cfg_path = vim.fn.getcwd() .. "/.nvim.lua"
local local_cfg = vim.secure.read(local_cfg_path)
if local_cfg then
  local ok, err = pcall(loadstring(local_cfg))
  if not ok then
    vim.notify("rust_analyzer local config error: " .. tostring(err), vim.log.levels.WARN)
  end
end
