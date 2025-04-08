-- Initialize core settings first
require("config.options")
require("config.keymaps")

-- Load plugin manager
require("config.lazy")

-- Plugin settings
require("config.plugins.mason")
require("config.plugins.treesitter")
require("config.plugins.lsp")
require("config.plugins.explorer")
require("config.plugins.whichkey")

-- Configure UI components last
require("config.theme")
