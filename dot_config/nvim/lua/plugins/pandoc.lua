-- A vimtex-like workflow for compiling Markdown to PDF using pandoc
return {
  "arminveres/md-pdf.nvim",
  lazy = true,
  -- Set up a keymap for compiling
  keys = {
    {
      "<Leader>mc",
      function()
        -- The plugin's main function to convert markdown to pdf
        require("md-pdf").convert_md_to_pdf()
      end,
      desc = "Markdown Compile",
    },
  },
  -- Configure the plugin
  opts = {
    -- Set zathura as the PDF viewer to match the vimtex setup
    preview_cmd = function()
      return "zathura"
    end,
    -- other options...
    ignore_viewer_state = true, -- Auto-recompile PDF on each write
  },
}
