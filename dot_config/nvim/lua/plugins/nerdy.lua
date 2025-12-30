---@type LazySpec
return {
  "2kabhishek/nerdy.nvim",
  cmd = "Nerdy",
  dependencies = {
    "folke/snacks.nvim",
  },
  opts = {
    max_recents = 30,
    add_default_keybindings = true,
    copy_to_clipboard = false,
    copy_register = "+",
  },
}
