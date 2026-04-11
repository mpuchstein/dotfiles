return {
  {
    "frabjous/knap",
    ft = { "markdown" },
    keys = {
      { "<leader>mp", function() require("knap").toggle_autopreviewing() end, ft = "markdown", desc = "Toggle live preview" },
      { "<leader>mj", function() require("knap").forward_jump() end,          ft = "markdown", desc = "SyncTeX forward jump"  },
    },
    config = function()
      vim.g.knap_settings = {
        -- markdown → PDF via pandoc
        mdoutputext          = "pdf",
        mdtopdf              = "pandoc %docroot% -o %outputfile% --pdf-engine=lualatex",
        mdtopdfviewerlaunch  = "zathura %outputfile%",
        mdtopdfviewerrefresh = "none", -- zathura watches the file itself
      }
    end,
  },
}
