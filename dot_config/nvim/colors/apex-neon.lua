-- Apex Neon: Standalone Theme Engine
-- Philosophy: State over Decoration. Red is Presence. Cyan is Data.

local M = {}

M.palette = {
  -- The Void
  void = "#050505", -- Background
  panel = "#141414", -- Dark Surface (Statusline/Gutter)
  border = "#262626", -- Muted Border
  stealth = "#404040", -- Comments / Ignored

  -- The Signal
  text = "#ededed", -- Stark White
  dim = "#737373", -- Muted Text

  -- The Hunter (Presence)
  razor = "#ff0044", -- PRIMARY: Cursor, Current Match, Active Border
  alert = "#ff8899", -- ERROR: Readable text on Red

  -- The HUD (Data)
  tech = "#00eaff", -- INFO: Selection, Search Match, Constants
  toxic = "#00ff99", -- SUCCESS: Strings
  amber = "#ffb700", -- WARNING: Types, Search
  azure = "#0088cc", -- STRUCT: Functions (Deep Blue)
  sacred = "#9d00ff", -- SPECIAL: Keywords, Root
}

function M.load()
  vim.cmd "hi clear"
  if vim.fn.exists "syntax_on" then vim.cmd "syntax reset" end
  vim.o.background = "dark"
  vim.g.colors_name = "apex-neon"

  -- Transparency: 80% opaque for floating UI
  vim.o.winblend = 20
  vim.o.pumblend = 20

  local p = M.palette
  local groups = {
    -- CANVAS & UI -----------------------------------------------------------
    Normal = { fg = p.text, bg = p.void },
    NormalNC = { fg = p.dim, bg = p.void }, -- Non-focused windows
    SignColumn = { bg = p.void },
    FoldColumn = { fg = p.stealth, bg = p.void },
    VertSplit = { fg = p.razor }, -- Deprecated in nvim 0.10, but good fallback
    WinSeparator = { fg = p.razor }, -- The Cage (Red Borders)
    EndOfBuffer = { fg = p.void }, -- Hide tildes

    -- CURSOR & NAVIGATION ("The Hunter") ------------------------------------
    Cursor = { fg = p.void, bg = p.razor }, -- Red Beam
    TermCursor = { fg = p.void, bg = p.razor },
    CursorLine = { bg = p.panel },
    CursorLineNr = { fg = p.razor, bold = true }, -- Red Line Number (You are here)
    LineNr = { fg = p.stealth }, -- Other lines fade out

    -- SELECTION & SEARCH ("Terminator Vision") ------------------------------
    Visual = { fg = p.void, bg = p.tech, bold = true }, -- Cyan (Data Lock)
    VisualNOS = { fg = p.void, bg = p.border },

    Search = { fg = p.void, bg = p.tech }, -- Cyan (Potential Targets)
    IncSearch = { fg = p.void, bg = p.razor }, -- Red (Acquiring...)
    CurSearch = { fg = p.void, bg = p.razor, bold = true }, -- Red (Target Locked)

    -- STATUS & MESSAGES -----------------------------------------------------
    StatusLine = { fg = p.text, bg = p.panel },
    StatusLineNC = { fg = p.dim, bg = p.void },
    WildMenu = { fg = p.void, bg = p.tech },
    Pmenu = { fg = p.text, bg = p.panel },
    PmenuSel = { fg = p.void, bg = p.razor, bold = true }, -- Red Menu Selection
    PmenuSbar = { bg = p.panel },
    PmenuThumb = { bg = p.stealth },

    -- SYNTAX HIGHLIGHTING ---------------------------------------------------
    Comment = { fg = p.stealth, italic = true },
    Constant = { fg = p.tech }, -- Cyan (Digital values)
    String = { fg = p.toxic }, -- Green (Organic strings)
    Character = { fg = p.toxic },
    Number = { fg = p.tech },
    Boolean = { fg = p.tech },
    Float = { fg = p.tech },

    Identifier = { fg = p.text }, -- Variables (White)
    Function = { fg = p.azure }, -- Deep Blue (Structure)

    Statement = { fg = p.sacred }, -- Purple (Keywords)
    Conditional = { fg = p.sacred },
    Repeat = { fg = p.sacred },
    Label = { fg = p.sacred },
    Operator = { fg = p.tech }, -- Cyan (Tech)
    Keyword = { fg = p.sacred },
    Exception = { fg = p.razor }, -- Red (Errors)

    PreProc = { fg = p.sacred },
    Include = { fg = p.sacred },
    Define = { fg = p.sacred },
    Macro = { fg = p.sacred },
    PreCondit = { fg = p.sacred },

    Type = { fg = p.amber }, -- Yellow (Types/Classes)
    StorageClass = { fg = p.amber },
    Structure = { fg = p.amber },
    Typedef = { fg = p.amber },

    Special = { fg = p.tech },
    SpecialChar = { fg = p.tech },
    Tag = { fg = p.tech },
    Delimiter = { fg = p.dim }, -- Subtle delimiters
    Debug = { fg = p.razor },

    Underlined = { underline = true },
    Ignore = { fg = p.stealth },
    Error = { fg = p.razor },
    Todo = { fg = p.void, bg = p.amber, bold = true },

    -- DIAGNOSTICS -----------------------------------------------------------
    DiagnosticError = { fg = p.razor },
    DiagnosticWarn = { fg = p.amber },
    DiagnosticInfo = { fg = p.tech },
    DiagnosticHint = { fg = p.dim },

    DiagnosticUnderlineError = { sp = p.razor, underline = true },
    DiagnosticUnderlineWarn = { sp = p.amber, underline = true },

    -- PLUGINS: TELESCOPE ("The HUD") ----------------------------------------
    TelescopeNormal = { bg = p.void },
    TelescopeBorder = { fg = p.razor, bg = p.void }, -- Red Border
    TelescopePromptNormal = { fg = p.text, bg = p.void },
    TelescopePromptBorder = { fg = p.tech, bg = p.void }, -- Cyan Input Border
    TelescopePromptTitle = { fg = p.void, bg = p.tech }, -- Cyan Label
    TelescopePreviewTitle = { fg = p.void, bg = p.razor }, -- Red Label
    TelescopeResultsTitle = { fg = p.void, bg = p.panel },
    TelescopeSelection = { fg = p.void, bg = p.razor }, -- Red Selection

    -- PLUGINS: NEO-TREE ("Stealth") -----------------------------------------
    NeoTreeNormal = { bg = p.void },
    NeoTreeNormalNC = { bg = p.void },
    NeoTreeVertSplit = { fg = p.panel, bg = p.void },
    NeoTreeWinSeparator = { fg = p.panel, bg = p.void }, -- Fade out tree border
    NeoTreeRootName = { fg = p.razor, bold = true }, -- Root is Red
    NeoTreeGitAdded = { fg = p.toxic },
    NeoTreeGitConflict = { fg = p.amber },
    NeoTreeGitDeleted = { fg = p.razor },
    NeoTreeGitModified = { fg = p.tech },

    -- PLUGINS: GITSIGNS -----------------------------------------------------
    GitSignsAdd = { fg = p.toxic, bg = p.void },
    GitSignsChange = { fg = p.tech, bg = p.void },
    GitSignsDelete = { fg = p.razor, bg = p.void },

    -- PLUGINS: CMP (Completion) ---------------------------------------------
    CmpItemAbbrDeprecated = { fg = p.dim, strikethrough = true },
    CmpItemAbbrMatch = { fg = p.tech, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = p.tech, bold = true },
    CmpItemKindFunction = { fg = p.azure },
    CmpItemKindMethod = { fg = p.azure },
    CmpItemKindKeyword = { fg = p.sacred },
    CmpItemKindVariable = { fg = p.text },
  }

  for group, highlight in pairs(groups) do
    vim.api.nvim_set_hl(0, group, highlight)
  end
end

M.load()

return M