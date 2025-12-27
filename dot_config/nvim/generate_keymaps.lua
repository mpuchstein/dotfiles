-- This script generates a Markdown cheatsheet of user-facing Neovim keymaps.

-- A table to map mode short names to full names
local modes = {
  n = "Normal",
  v = "Visual",
  i = "Insert",
  x = "Visual Block",
  s = "Select",
  o = "Operator Pending",
  t = "Terminal",
}

-- The final output will be collected here
local output = { "# Neovim Keymap Cheatsheet", "" }

-- Iterate over each mode to get its keymaps
for mode_key, mode_name in pairs(modes) do
  -- Add a header for the current mode
  table.insert(output, "## " .. mode_name .. " Mode")
  table.insert(output, "")
  table.insert(output, "| Keymap | Description |")
  table.insert(output, "|---|---|")

  local keymaps = vim.api.nvim_get_keymap(mode_key)
  local processed_maps = {}

  -- Process and filter keymaps
  for _, keymap in ipairs(keymaps) do
    -- We only want user-facing keymaps, which typically have a description.
    -- We also filter out internal <Plug> mappings and empty mappings.
    if keymap.desc and keymap.desc ~= "" and not vim.startswith(keymap.lhs, "<Plug>") then
      -- Use a table to store unique mappings to avoid duplicates, prioritizing those without 'nowait'
      local key = keymap.lhs .. "|" .. keymap.desc
      if not processed_maps[key] or processed_maps[key].nowait then
        processed_maps[key] = keymap
      end
    end
  end

  -- Sort the processed keymaps by the key sequence (lhs)
  local sorted_maps = {}
  for _, keymap in pairs(processed_maps) do
    table.insert(sorted_maps, keymap)
  end
  table.sort(sorted_maps, function(a, b) return a.lhs < b.lhs end)

  -- Add the sorted keymaps to the output
  for _, keymap in ipairs(sorted_maps) do
    table.insert(output, string.format("| `%s` | %s |", keymap.lhs, keymap.desc))
  end
  table.insert(output, "") -- Add a blank line for spacing
end

-- Write the collected output to the cheatsheet file
local file = io.open("keymap_cheatsheet.md", "w")
if file then
  file:write(table.concat(output, "\n"))
  file:close()
  print("Successfully generated keymap_cheatsheet.md")
else
  print("Error: Could not open file for writing.")
end
