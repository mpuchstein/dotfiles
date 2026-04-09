return {
  -- Debug Adapter Protocol base
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end,                                         desc = "Toggle breakpoint"      },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,                 desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,                                                  desc = "Continue"               },
      { "<leader>di", function() require("dap").step_into() end,                                                 desc = "Step into"              },
      { "<leader>do", function() require("dap").step_over() end,                                                 desc = "Step over"              },
      { "<leader>dO", function() require("dap").step_out() end,                                                  desc = "Step out"               },
      { "<leader>dr", function() require("dap").repl.open() end,                                                 desc = "Open REPL"              },
      { "<leader>du", function() require("dapui").toggle() end,                                                  desc = "Toggle DAP UI"          },
      { "<leader>dv", function() require("nvim-dap-virtual-text").toggle() end,                                  desc = "Toggle virtual text"    },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Auto-open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

      -- Load language-specific configs
      require("plugins.dap.rust")
      require("plugins.dap.js")
    end,
  },

  -- DAP UI panels
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {
      icons = { expanded = "", collapsed = "", current_frame = "" },
      layouts = {
        {
          elements = {
            { id = "scopes",      size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks",      size = 0.25 },
            { id = "watches",     size = 0.25 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl",    size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 10,
          position = "bottom",
        },
      },
    },
  },

  -- Inline variable values during debug session
  {
    "theHamsta/nvim-dap-virtual-text",
    lazy = true,
    opts = {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      commented = false,
      virt_text_pos = "eol",
    },
  },
}
