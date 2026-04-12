return {
  -- Seamless navigation between nvim splits and tmux panes
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {
      multiplexer_integration = "tmux",
      cursor_follows_swapped_panes = false,
    },
    keys = {
      -- Navigate
      { "<A-h>", function() require("smart-splits").move_cursor_left()  end, mode = { "n", "t" }, desc = "Move to left split/pane"  },
      { "<A-j>", function() require("smart-splits").move_cursor_down()  end, mode = { "n", "t" }, desc = "Move to lower split/pane" },
      { "<A-k>", function() require("smart-splits").move_cursor_up()    end, mode = { "n", "t" }, desc = "Move to upper split/pane" },
      { "<A-l>", function() require("smart-splits").move_cursor_right() end, mode = { "n", "t" }, desc = "Move to right split/pane" },
      -- Resize
      { "<C-A-h>", function() require("smart-splits").resize_left()  end, desc = "Resize left"  },
      { "<C-A-j>", function() require("smart-splits").resize_down()  end, desc = "Resize down"  },
      { "<C-A-k>", function() require("smart-splits").resize_up()    end, desc = "Resize up"    },
      { "<C-A-l>", function() require("smart-splits").resize_right() end, desc = "Resize right" },
    },
  },

  -- Breadcrumbs: current file > class > method via LSP
  {
    "SmiteshP/nvim-navic",
    lazy = true, -- attached via LspAttach in autocmds.lua
    opts = {
      icons = {
        File = "󰈙 ", Module = " ", Namespace = "󰌗 ", Package = " ",
        Class = "󰌗 ", Method = "󰆧 ", Property = " ", Field = " ",
        Constructor = " ", Enum = "󰕘", Interface = "󰕘", Function = "󰊕 ",
        Variable = "󰆧 ", Constant = "󰏿 ", String = "󰀬 ", Number = "󰎠 ",
        Boolean = "◩ ", Array = "󰅪 ", Object = "󰅩 ", Key = "󰌋 ",
        Null = "󰟢 ", EnumMember = " ", Struct = "󰌗 ", Event = " ",
        Operator = "󰆕 ", TypeParameter = "󰊄 ",
      },
      lsp = { auto_attach = false }, -- we attach manually in autocmds.lua
      highlight = true,
      separator = " › ",
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
    event = "VeryLazy",
    config = function()
      local navic = require("nvim-navic")
      require("lualine").setup({
        options = {
          theme = require("apex-neon").lualine,
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = {
            {
              -- Show recording macro indicator
              function()
                local reg = vim.fn.reg_recording()
                return reg ~= "" and "Recording @" .. reg or ""
              end,
              color = { fg = "#ffb700" },
            },
            "encoding", "fileformat", "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        winbar = {
          lualine_c = {
            {
              function()
                return navic.is_available() and navic.get_location() or ""
              end,
            },
          },
        },
        inactive_winbar = {
          lualine_c = { { "filename", path = 1 } },
        },
      })
    end,
  },

  -- Buffer tabs at top
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    opts = {
      options = {
        mode = "buffers",
        separator_style = "slant",
        show_buffer_close_icons = true,
        show_close_icon = false,
        color_icons = true,
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "aerial", text = "Symbols", text_align = "center", separator = true },
        },
      },
    },
  },

  -- Scoped buffers per tab
  {
    "tiagovla/scope.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Keymap discovery
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      icons = { mappings = false },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>f",  group = "Find / Telescope" },
        { "<leader>g",  group = "Git" },
        { "<leader>l",  group = "LSP" },
        { "<leader>r",  group = "Refactor" },
        { "<leader>x",  group = "Diagnostics / Trouble" },
        { "<leader>d",  group = "Debug (DAP)" },
        { "<leader>t",  group = "Test" },
        { "<leader>u",  group = "UI Toggles" },
        { "<leader>S",  group = "Sessions" },
        { "<leader>j",  group = "Java" },
        { "<leader>c",  group = "AI / Claude" },
        { "<leader>h",  group = "Git Hunks" },
      })

      -- UI toggle keymaps (no plugin dependency)
      local map = vim.keymap.set
      map("n", "<leader>uw", function() vim.opt.wrap = not vim.wo.wrap end, { desc = "Toggle wrap" })
      map("n", "<leader>uf", "zA", { desc = "Toggle all folds" })
    end,
  },

  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>ui", "<cmd>IBLToggle<cr>", desc = "Toggle indent guides" },
    },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
    },
  },

  -- Rendered markdown in buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      heading = { enabled = true },
      code = { enabled = true, style = "full" },
      bullet = { enabled = true },
    },
  },

  -- File explorer as buffer
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil --float<cr>", desc = "Open oil (float)" },
    },
    opts = {
      default_file_explorer = true,
      float = { padding = 2 },
      view_options = { show_hidden = true },
    },
  },

  -- Symbols outline panel
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>uo", "<cmd>AerialToggle!<cr>", desc = "Symbols outline" },
    },
    opts = {
      attach_mode = "global",
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = { min_width = 28 },
      show_guides = true,
    },
  },

  -- Diagnostics list
  {
    "folke/trouble.nvim",
    version = "v3.*",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Workspace diagnostics" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Document diagnostics"  },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix list"         },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location list"         },
      { "<leader>xs", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP definitions"       },
    },
    opts = { use_diagnostic_signs = true },
  },

  -- Better notifications
  {
    "rcarriga/nvim-notify",
    lazy = false,
    priority = 1000,
    config = function()
      local notify = require("notify")
      notify.setup({
        timeout = 3000,
        max_width = 80,
        stages = "fade_in_slide_out",
        render = "default",
        background_colour = "#050505",
      })
      vim.notify = notify
    end,
    keys = {
      { "<leader>un", function() require("notify").dismiss({ silent = true, pending = true }) end, desc = "Dismiss notifications" },
    },
  },

  -- Sign column + fold gutter management
  {
    "luukvbaal/statuscol.nvim",
    event = "BufReadPost",
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = true,
        segments = {
          { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
          { text = { "%s" },                  click = "v:lua.ScSa" },
          { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
        },
      })
    end,
  },

  -- Scrollbar with diagnostic + git marks
  {
    "lewis6991/satellite.nvim",
    event = "BufReadPost",
    opts = {
      current_only = false,
      winblend = 50,
      handlers = {
        cursor   = { enable = true },
        search   = { enable = true },
        marks    = { enable = true },
        quickfix = { enable = false },
        gitsigns = { enable = true },
        diagnostics = { enable = true, min_severity = vim.diagnostic.severity.WARN },
      },
    },
  },

  -- Session save/restore per directory
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { dir = vim.fn.stdpath("state") .. "/sessions/" },
    keys = {
      { "<leader>Ss", function() require("persistence").save()                end, desc = "Save session"    },
      { "<leader>Sr", function() require("persistence").load()                end, desc = "Restore session" },
      { "<leader>Sl", function() require("persistence").load({ last = true }) end, desc = "Last session"    },
    },
  },

  -- Project-wide search and replace
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", "<cmd>GrugFar<cr>",                                                                         desc = "Search & replace" },
      { "<leader>rs", "<cmd>GrugFar<cr>",                                                                         desc = "Search & replace" },
      { "<leader>sw", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end, desc = "Search word"    },
    },
    opts = { headerMaxWidth = 80 },
  },

  -- Code action preview (diff before applying)
  {
    "aznhe21/actions-preview.nvim",
    event = "LspAttach",
    keys = {
      { "<leader>la", function() require("actions-preview").code_actions() end, mode = { "n", "v" }, desc = "Code actions (preview)" },
    },
    opts = {},
  },

  -- Multi-cursor (Ctrl+N equivalent)
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-n>",
        ["Find Subword Under"] = "<C-n>",
      }
    end,
  },

  -- Project switcher (auto-detect project root)
  {
    "ahmedkhalf/project.nvim",
    lazy = false,
    config = function()
      require("project_nvim").setup({
        detection_methods = { "lsp", "pattern" },
        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "Cargo.toml" },
        silent_chdir = true,
      })
    end,
  },

  -- UI Toggles
  -- (wrap, fold, spell are just keymap + vim.opt calls — no plugin needed)
}
