-- Initialize core settings first
require("config.options")
require("config.keymaps")

-- Load plugin manager
require("config.lazy")

-- Plugin settings
require("config.plugins.treesitter")

-- Configure UI components last
require("config.theme")
