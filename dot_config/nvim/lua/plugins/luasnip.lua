return {
  "L3MON4D3/LuaSnip",
  enabled = true,
  version = "v2.*",
  build = "make install_jsregexp",
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function(plugin, opts)
    -- run the default astronvim config that calls the setup call
    require "astronvim.plugins.configs.luasnip"(plugin, opts)
    -- lazy load snippets from friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()
    -- add more custom luasnip configuration such as filetype extend or custom snippets
    require("luasnip").filetype_extend("javascript", { "javascriptreact" })
  end,
}
