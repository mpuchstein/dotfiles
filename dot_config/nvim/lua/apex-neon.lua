-- Proxy so require("apex-neon") returns the colorscheme module
-- colors/apex-neon.lua is managed by refresh-apex-themes — do not edit that file
-- This shim is safe to keep in chezmoi alongside the colors/ file
local colors_path = vim.fn.stdpath("config") .. "/colors/apex-neon.lua"
local ok, result = pcall(dofile, colors_path)
if not ok then
  vim.notify("apex-neon shim: failed to load " .. colors_path, vim.log.levels.WARN)
  return {}
end
return result
