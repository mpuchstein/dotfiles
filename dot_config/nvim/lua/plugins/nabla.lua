-- Lightweight inline ASCII preview for LaTeX math
return {
  "jbyuki/nabla.nvim",
  ft = { "tex", "plaintex", "markdown" },
  keys = {
    -- Popup preview for the expression under cursor
    { "<leader>mp", function() require("nabla").popup() end, desc = "Math: popup preview" },

    -- Toggle inline virtual rendering; re-enable wrap after toggle (nabla toggles it off)
    {
      "<leader>mv",
      function()
        require("nabla").toggle_virt { autogen = true }
        vim.wo.wrap = true
      end,
      desc = "Math: toggle inline preview",
    },
  },
}
