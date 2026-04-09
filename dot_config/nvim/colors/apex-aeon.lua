-- Apex Aeon: Standalone Theme Engine
-- Philosophy: State over Decoration. Red is Presence. Cyan is Data.

local M = {}

M.palette = {
  -- The Void
  void = "#f5f5f5", -- Background
  panel = "#e8e8e8", -- Dark Surface (Statusline/Gutter)
  border = "#737373", -- Muted Border
  stealth = "#a0a0a0", -- Comments / Ignored

  -- The Signal
  text = "#0a0a0a", -- Stark White
  dim = "#737373", -- Muted Text

  -- The Hunter (Presence)
  razor = "#ff0044", -- PRIMARY: Cursor, Current Match, Active Border
  ink = "#0a0a0a", -- Text color on Razor backgrounds
  alert = "#ff0044", -- Error accent text on void/panel

  -- The HUD (Data)
  tech = "#007a88", -- INFO: Selection, Search Match, Constants
  toxic = "#00b377", -- SUCCESS: Strings
  amber = "#d18f00", -- WARNING: Types, Search
  azure = "#005577", -- STRUCT: Functions (Deep Blue)
  sacred = "#7a3cff", -- SPECIAL: Keywords, Root
}

function M.load()
  vim.cmd "hi clear"
  if vim.fn.exists "syntax_on" then vim.cmd "syntax reset" end
  vim.o.background = "light"
  vim.g.colors_name = "apex-aeon"

  -- Optional transparency: set g:apex_blend or g:apex_transparent to opt in.
  local blend = vim.g.apex_blend
  if type(blend) == "number" then
    vim.o.winblend = blend
    vim.o.pumblend = blend
  elseif vim.g.apex_transparent == true then
    vim.o.winblend = 20
    vim.o.pumblend = 20
  end

  local p = M.palette
  local groups = {
    -- CANVAS & UI -----------------------------------------------------------
    Normal = { fg = p.text, bg = p.void },
    NormalNC = { fg = p.dim, bg = p.void }, -- Non-focused windows
    SignColumn = { bg = p.void },
    FoldColumn = { fg = p.stealth, bg = p.void },
    VertSplit = { fg = p.border }, -- Deprecated in nvim 0.10, but good fallback
    WinSeparator = { fg = p.border },
    EndOfBuffer = { fg = p.void }, -- Hide tildes
    NormalFloat = { fg = p.text, bg = p.panel },
    FloatBorder = { fg = p.border, bg = p.panel },
    MsgArea = { fg = p.text, bg = p.void },
    WinBar = { fg = p.text, bg = p.panel },
    WinBarNC = { fg = p.dim, bg = p.panel },

    -- CURSOR & NAVIGATION ("The Hunter") ------------------------------------
    Cursor = { fg = p.ink, bg = p.razor }, -- Red Beam
    TermCursor = { fg = p.ink, bg = p.razor },
    CursorLine = { bg = p.panel },
    CursorColumn = { bg = p.panel },
    ColorColumn = { bg = p.panel },
    CursorLineNr = { fg = p.razor, bold = true }, -- Red Line Number (You are here)
    LineNr = { fg = p.stealth }, -- Other lines fade out

    -- SELECTION & SEARCH ("Terminator Vision") ------------------------------
    Visual = { fg = p.void, bg = p.tech, bold = true }, -- Cyan (Data Lock)
    VisualNOS = { fg = p.void, bg = p.border },

    Search = { fg = p.void, bg = p.tech }, -- Cyan (Potential Targets)
    IncSearch = { fg = p.ink, bg = p.razor }, -- Red (Acquiring...)
    CurSearch = { fg = p.ink, bg = p.razor, bold = true }, -- Red (Target Locked)

    -- STATUS & MESSAGES -----------------------------------------------------
    StatusLine = { fg = p.text, bg = p.panel },
    StatusLineNC = { fg = p.dim, bg = p.void },
    WildMenu = { fg = p.void, bg = p.tech },
    Pmenu = { fg = p.text, bg = p.panel },
    PmenuSel = { fg = p.ink, bg = p.razor, bold = true }, -- Red Menu Selection
    PmenuKind = { fg = p.dim, bg = p.panel },
    PmenuKindSel = { fg = p.ink, bg = p.razor, bold = true },
    PmenuExtra = { fg = p.dim, bg = p.panel },
    PmenuExtraSel = { fg = p.ink, bg = p.razor, bold = true },
    PmenuMatch = { fg = p.tech, bg = p.panel, bold = true },
    PmenuMatchSel = { fg = p.ink, bg = p.razor, bold = true },
    PmenuSbar = { bg = p.panel },
    PmenuThumb = { bg = p.stealth },
    ErrorMsg = { fg = p.alert },
    WarningMsg = { fg = p.amber },
    MoreMsg = { fg = p.tech },
    ModeMsg = { fg = p.text },
    TabLine = { fg = p.dim, bg = p.panel },
    TabLineSel = { fg = p.text, bg = p.void, bold = true },
    TabLineFill = { fg = p.panel, bg = p.panel },
    QuickFixLine = { fg = p.text, bg = p.panel, bold = true },

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
    Operator = { fg = p.text }, -- White (Neutral)
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

    Special = { fg = p.sacred },    -- Purple (special grammar tokens)
    SpecialChar = { fg = p.amber }, -- Amber (escalated string variant: escapes, regex)
    Tag = { fg = p.azure },         -- Blue (structural: HTML/XML tags)
    Delimiter = { fg = p.dim }, -- Subtle delimiters
    Debug = { fg = p.razor },

    Underlined = { underline = true },
    Ignore = { fg = p.stealth },
    Error = { fg = p.alert },
    Todo = { fg = p.void, bg = p.amber, bold = true },
    Title = { fg = p.sacred, bold = true },

    MatchParen = { fg = p.void, bg = p.amber, bold = true },
    Whitespace = { fg = p.border },
    NonText = { fg = p.border },
    SpecialKey = { fg = p.border },
    SpellBad = { sp = p.razor, undercurl = true },
    SpellCap = { sp = p.amber, undercurl = true },
    SpellRare = { sp = p.tech, undercurl = true },
    SpellLocal = { sp = p.dim, undercurl = true },
    LspReferenceText = { bg = p.panel },
    LspReferenceRead = { bg = p.panel },
    LspReferenceWrite = { bg = p.panel, bold = true },
    LspSignatureActiveParameter = { fg = p.void, bg = p.tech, bold = true },
    LspInlayHint = { fg = p.dim, bg = p.panel },
    LspCodeLens = { fg = p.dim },
    LspCodeLensSeparator = { fg = p.stealth },
    LspInfoBorder = { fg = p.border, bg = p.panel },
    LspInfoTitle = { fg = p.dim, bg = p.panel },

    -- DIAGNOSTICS -----------------------------------------------------------
    DiagnosticError = { fg = p.alert },
    DiagnosticWarn = { fg = p.amber },
    DiagnosticInfo = { fg = p.tech },
    DiagnosticHint = { fg = p.dim },
    DiagnosticOk = { fg = p.toxic },
    DiagnosticDeprecated = { fg = p.dim, strikethrough = true },
    DiagnosticUnnecessary = { fg = p.dim },

    DiagnosticUnderlineError = { undercurl = true, sp = p.razor },
    DiagnosticUnderlineWarn = { undercurl = true, sp = p.amber },
    DiagnosticUnderlineInfo = { undercurl = true, sp = p.tech },
    DiagnosticUnderlineHint = { undercurl = true, sp = p.dim },
    DiagnosticUnderlineOk = { undercurl = true, sp = p.toxic },
    DiagnosticVirtualTextError = { fg = p.alert, bg = p.panel },
    DiagnosticVirtualTextWarn = { fg = p.amber, bg = p.panel },
    DiagnosticVirtualTextInfo = { fg = p.tech, bg = p.panel },
    DiagnosticVirtualTextHint = { fg = p.dim, bg = p.panel },
    DiagnosticVirtualTextOk = { fg = p.toxic, bg = p.panel },
    DiagnosticVirtualLinesError = { fg = p.alert, bg = p.panel },
    DiagnosticVirtualLinesWarn = { fg = p.amber, bg = p.panel },
    DiagnosticVirtualLinesInfo = { fg = p.tech, bg = p.panel },
    DiagnosticVirtualLinesHint = { fg = p.dim, bg = p.panel },
    DiagnosticVirtualLinesOk = { fg = p.toxic, bg = p.panel },
    DiagnosticSignError = { fg = p.alert, bg = p.void },
    DiagnosticSignWarn = { fg = p.amber, bg = p.void },
    DiagnosticSignInfo = { fg = p.tech, bg = p.void },
    DiagnosticSignHint = { fg = p.dim, bg = p.void },
    DiagnosticSignOk = { fg = p.toxic, bg = p.void },
    DiagnosticFloatingError = { fg = p.alert, bg = p.panel },
    DiagnosticFloatingWarn = { fg = p.amber, bg = p.panel },
    DiagnosticFloatingInfo = { fg = p.tech, bg = p.panel },
    DiagnosticFloatingHint = { fg = p.dim, bg = p.panel },
    DiagnosticFloatingOk = { fg = p.toxic, bg = p.panel },
    ApexMarkupStrong = { bold = true },
    ApexMarkupItalic = { italic = true },
    ApexMarkupLink = { fg = p.tech, underline = true },

    -- DIFF ------------------------------------------------------------------
    DiffAdd = { fg = p.toxic, bg = p.panel },
    DiffChange = { fg = p.tech, bg = p.panel },
    DiffDelete = { fg = p.razor, bg = p.panel },
    DiffText = { fg = p.void, bg = p.tech, bold = true },

    -- PLUGINS: TELESCOPE ("The HUD") ----------------------------------------
    TelescopeNormal = { bg = p.void },
    TelescopeBorder = { fg = p.razor, bg = p.void }, -- Red Border
    TelescopePromptNormal = { fg = p.text, bg = p.void },
    TelescopePromptBorder = { fg = p.tech, bg = p.void }, -- Cyan Input Border
    TelescopePromptTitle = { fg = p.void, bg = p.tech }, -- Cyan Label
    TelescopePreviewTitle = { fg = p.ink, bg = p.razor }, -- Red Label
    TelescopeResultsTitle = { fg = p.void, bg = p.panel },
    TelescopeSelection = { fg = p.ink, bg = p.razor }, -- Red Selection

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

    -- PLUGINS: BLINK.CMP (Completion) ----------------------------------------
    BlinkCmpMenu             = { fg = p.text, bg = p.panel },
    BlinkCmpMenuBorder       = { fg = p.border, bg = p.panel },
    BlinkCmpMenuSelection    = { fg = p.ink, bg = p.razor, bold = true },
    BlinkCmpScrollBarThumb   = { bg = p.stealth },
    BlinkCmpScrollBarGutter  = { bg = p.panel },
    BlinkCmpLabel            = { fg = p.text },
    BlinkCmpLabelDeprecated  = { fg = p.dim, strikethrough = true },
    BlinkCmpLabelMatch       = { fg = p.tech, bold = true },
    BlinkCmpKindText         = { fg = p.text },
    BlinkCmpKindMethod       = { fg = p.azure },
    BlinkCmpKindFunction     = { fg = p.azure },
    BlinkCmpKindConstructor  = { fg = p.amber },
    BlinkCmpKindField        = { fg = p.text },
    BlinkCmpKindVariable     = { fg = p.text },
    BlinkCmpKindClass        = { fg = p.amber },
    BlinkCmpKindInterface    = { fg = p.amber },
    BlinkCmpKindModule       = { fg = p.amber },
    BlinkCmpKindProperty     = { fg = p.text },
    BlinkCmpKindUnit         = { fg = p.tech },
    BlinkCmpKindValue        = { fg = p.tech },
    BlinkCmpKindEnum         = { fg = p.amber },
    BlinkCmpKindKeyword      = { fg = p.sacred },
    BlinkCmpKindSnippet      = { fg = p.toxic },
    BlinkCmpKindColor        = { fg = p.tech },
    BlinkCmpKindFile         = { fg = p.text },
    BlinkCmpKindReference    = { fg = p.tech },
    BlinkCmpKindFolder       = { fg = p.text },
    BlinkCmpKindEnumMember   = { fg = p.tech },
    BlinkCmpKindConstant     = { fg = p.tech },
    BlinkCmpKindStruct       = { fg = p.amber },
    BlinkCmpKindEvent        = { fg = p.amber },
    BlinkCmpKindOperator     = { fg = p.text },
    BlinkCmpKindTypeParameter = { fg = p.amber },
    BlinkCmpGhostText        = { fg = p.stealth, italic = true },
    BlinkCmpDoc              = { fg = p.text, bg = p.panel },
    BlinkCmpDocBorder        = { fg = p.border, bg = p.panel },
    BlinkCmpDocSeparator     = { fg = p.border, bg = p.panel },
    BlinkCmpDocCursorLine    = { bg = p.border },
    BlinkCmpSignatureHelp    = { fg = p.text, bg = p.panel },
    BlinkCmpSignatureHelpBorder = { fg = p.border, bg = p.panel },
    BlinkCmpSignatureHelpActiveParameter = { fg = p.ink, bg = p.tech, bold = true },
    BlinkCmpSource           = { fg = p.dim },

    -- PLUGINS: BUFFERLINE -----------------------------------------------------
    BufferLineBackground        = { fg = p.dim, bg = p.panel },
    BufferLineFill              = { bg = p.panel },
    BufferLineBuffer            = { fg = p.dim, bg = p.panel },
    BufferLineBufferSelected    = { fg = p.text, bg = p.void, bold = true },
    BufferLineBufferVisible     = { fg = p.dim, bg = p.panel },
    BufferLineTab               = { fg = p.dim, bg = p.panel },
    BufferLineTabSelected       = { fg = p.text, bg = p.void, bold = true },
    BufferLineTabClose          = { fg = p.razor, bg = p.panel },
    BufferLineModified          = { fg = p.tech, bg = p.panel },
    BufferLineModifiedSelected  = { fg = p.tech, bg = p.void },
    BufferLineModifiedVisible   = { fg = p.tech, bg = p.panel },
    BufferLineSeparator         = { fg = p.border, bg = p.panel },
    BufferLineSeparatorSelected = { fg = p.border, bg = p.void },
    BufferLineSeparatorVisible  = { fg = p.border, bg = p.panel },
    BufferLineIndicatorSelected = { fg = p.razor, bg = p.void },
    BufferLineCloseButton       = { fg = p.dim, bg = p.panel },
    BufferLineCloseButtonSelected = { fg = p.razor, bg = p.void },
    BufferLineCloseButtonVisible  = { fg = p.dim, bg = p.panel },
    BufferLineDiagnostic           = { fg = p.dim, bg = p.panel },
    BufferLineDiagnosticSelected   = { fg = p.dim, bg = p.void },
    BufferLineError                = { fg = p.alert, bg = p.panel },
    BufferLineErrorSelected        = { fg = p.alert, bg = p.void, bold = true },
    BufferLineWarning              = { fg = p.amber, bg = p.panel },
    BufferLineWarningSelected      = { fg = p.amber, bg = p.void, bold = true },
    BufferLineInfo                 = { fg = p.tech, bg = p.panel },
    BufferLineInfoSelected         = { fg = p.tech, bg = p.void, bold = true },
    BufferLineHint                 = { fg = p.dim, bg = p.panel },
    BufferLineHintSelected         = { fg = p.dim, bg = p.void, bold = true },
    BufferLinePick                 = { fg = p.razor, bg = p.panel, bold = true },
    BufferLinePickSelected         = { fg = p.razor, bg = p.void, bold = true },
    BufferLinePickVisible          = { fg = p.razor, bg = p.panel, bold = true },

    -- PLUGINS: WHICH-KEY ------------------------------------------------------
    WhichKey            = { fg = p.razor, bold = true },
    WhichKeySeparator   = { fg = p.stealth },
    WhichKeyGroup       = { fg = p.tech },
    WhichKeyDesc        = { fg = p.text },
    WhichKeyFloat       = { bg = p.panel },
    WhichKeyBorder      = { fg = p.border, bg = p.panel },
    WhichKeyTitle       = { fg = p.ink, bg = p.razor, bold = true },
    WhichKeyNormal      = { fg = p.text, bg = p.panel },
    WhichKeyValue       = { fg = p.dim },
    WhichKeyIcon        = { fg = p.azure },
    WhichKeyIconAzure   = { fg = p.azure },
    WhichKeyIconGreen   = { fg = p.toxic },
    WhichKeyIconYellow  = { fg = p.amber },
    WhichKeyIconRed     = { fg = p.razor },
    WhichKeyIconPurple  = { fg = p.sacred },
    WhichKeyIconCyan    = { fg = p.tech },

    -- PLUGINS: TROUBLE --------------------------------------------------------
    TroubleNormal       = { fg = p.text, bg = p.void },
    TroubleNormalNC     = { fg = p.dim, bg = p.void },
    TroubleText         = { fg = p.text },
    TroubleCount        = { fg = p.ink, bg = p.razor, bold = true },
    TroubleError        = { fg = p.alert },
    TroubleWarning      = { fg = p.amber },
    TroubleHint         = { fg = p.dim },
    TroubleInfo         = { fg = p.tech },
    TroubleSource       = { fg = p.dim },
    TroubleCode         = { fg = p.stealth },
    TroubleLocation     = { fg = p.dim },
    TroubleFile         = { fg = p.tech, bold = true },
    TroubleIndent       = { fg = p.border },
    TroublePos          = { fg = p.dim },
    TroubleSignError    = { fg = p.alert },
    TroubleSignWarning  = { fg = p.amber },
    TroubleSignHint     = { fg = p.dim },
    TroubleSignInfo     = { fg = p.tech },
    TroublePreview      = { fg = p.ink, bg = p.razor },
    TroubleFocusText    = { fg = p.text, bold = true },

    -- PLUGINS: INDENT-BLANKLINE -----------------------------------------------
    IblIndent     = { fg = p.border },
    IblScope      = { fg = p.stealth },
    IblWhitespace = { fg = p.border },

    -- PLUGINS: NEOGIT ---------------------------------------------------------
    NeogitBranch                = { fg = p.razor, bold = true },
    NeogitRemote                = { fg = p.tech },
    NeogitHunkHeader            = { fg = p.text, bg = p.panel, bold = true },
    NeogitHunkHeaderHighlight   = { fg = p.ink, bg = p.tech, bold = true },
    NeogitDiffAdd               = { fg = p.toxic, bg = p.void },
    NeogitDiffDelete            = { fg = p.razor, bg = p.void },
    NeogitDiffContext           = { fg = p.dim, bg = p.void },
    NeogitDiffAddHighlight      = { fg = p.toxic, bg = p.panel },
    NeogitDiffDeleteHighlight   = { fg = p.razor, bg = p.panel },
    NeogitDiffContextHighlight  = { fg = p.text, bg = p.panel },
    NeogitCommitViewHeader      = { fg = p.ink, bg = p.razor, bold = true },
    NeogitFilePath              = { fg = p.tech, underline = true },
    NeogitDiffHeader            = { fg = p.amber, bold = true },
    NeogitDiffHeaderHighlight   = { fg = p.ink, bg = p.amber, bold = true },
    NeogitObjectId              = { fg = p.dim },
    NeogitStashes               = { fg = p.sacred },
    NeogitRebaseDone            = { fg = p.toxic },
    NeogitFold                  = { fg = p.stealth },

    -- PLUGINS: AERIAL (Symbols Outline) --------------------------------------
    AerialLine          = { fg = p.ink, bg = p.razor },
    AerialLineNC        = { fg = p.dim, bg = p.panel },
    AerialNormal        = { fg = p.text, bg = p.void },
    AerialGuide         = { fg = p.border },
    AerialClass         = { fg = p.amber },
    AerialClassIcon     = { fg = p.amber },
    AerialFunction      = { fg = p.azure },
    AerialFunctionIcon  = { fg = p.azure },
    AerialMethod        = { fg = p.azure },
    AerialMethodIcon    = { fg = p.azure },
    AerialConstructor   = { fg = p.amber },
    AerialField         = { fg = p.text },
    AerialVariable      = { fg = p.text },
    AerialEnum          = { fg = p.amber },
    AerialEnumIcon      = { fg = p.amber },
    AerialInterface     = { fg = p.amber },
    AerialModule        = { fg = p.amber },
    AerialNamespace     = { fg = p.amber },
    AerialPackage       = { fg = p.amber },
    AerialProperty      = { fg = p.text },
    AerialStruct        = { fg = p.amber },
    AerialType          = { fg = p.amber },
    AerialTypeParameter = { fg = p.amber },
    AerialConstant      = { fg = p.tech },
    AerialString        = { fg = p.toxic },
    AerialNumber        = { fg = p.tech },
    AerialBoolean       = { fg = p.tech },
    AerialKey           = { fg = p.sacred },
    AerialKeyword       = { fg = p.sacred },
    AerialOperator      = { fg = p.text },
    AerialNull          = { fg = p.dim },
    AerialArray         = { fg = p.tech },
    AerialObject        = { fg = p.amber },
    AerialEvent         = { fg = p.amber },

    -- PLUGINS: DAP-UI ---------------------------------------------------------
    DapUIScope                    = { fg = p.tech, bold = true },
    DapUIType                     = { fg = p.amber },
    DapUIDecoration               = { fg = p.border },
    DapUIThread                   = { fg = p.toxic },
    DapUIStoppedThread            = { fg = p.razor, bold = true },
    DapUICurrentFrameName         = { fg = p.razor, bold = true },
    DapUISource                   = { fg = p.dim },
    DapUILineNumber               = { fg = p.stealth },
    DapUIFloatBorder              = { fg = p.border, bg = p.panel },
    DapUIFloatNormal              = { fg = p.text, bg = p.panel },
    DapUIWatchesEmpty             = { fg = p.dim },
    DapUIWatchesValue             = { fg = p.toxic },
    DapUIWatchesError             = { fg = p.alert },
    DapUIBreakpointsPath          = { fg = p.tech },
    DapUIBreakpointsInfo          = { fg = p.dim },
    DapUIBreakpointsCurrentLine   = { fg = p.razor, bold = true },
    DapUIBreakpointsDisabledLine  = { fg = p.stealth },
    DapUIEndofBuffer              = { fg = p.void },
    DapUIModifiedValue            = { fg = p.amber, bold = true },
    DapUIStop                     = { fg = p.razor },
    DapUIStepOver                 = { fg = p.tech },
    DapUIStepInto                 = { fg = p.tech },
    DapUIStepBack                 = { fg = p.tech },
    DapUIStepOut                  = { fg = p.tech },
    DapUIRestart                  = { fg = p.toxic },
    DapUIUnavailable              = { fg = p.stealth },
    DapUIPlayPause                = { fg = p.toxic },

    -- PLUGINS: DAP VIRTUAL TEXT -----------------------------------------------
    NvimDapVirtualText        = { fg = p.dim, italic = true },
    NvimDapVirtualTextChanged = { fg = p.amber, italic = true },
    NvimDapVirtualTextError   = { fg = p.alert, italic = true },
    NvimDapVirtualTextInfo    = { fg = p.tech, italic = true },

    -- PLUGINS: NVIM-NOTIFY ----------------------------------------------------
    NotifyERRORBorder = { fg = p.razor },
    NotifyWARNBorder  = { fg = p.amber },
    NotifyINFOBorder  = { fg = p.tech },
    NotifyDEBUGBorder = { fg = p.stealth },
    NotifyTRACEBorder = { fg = p.sacred },
    NotifyERRORIcon   = { fg = p.razor },
    NotifyWARNIcon    = { fg = p.amber },
    NotifyINFOIcon    = { fg = p.tech },
    NotifyDEBUGIcon   = { fg = p.stealth },
    NotifyTRACEIcon   = { fg = p.sacred },
    NotifyERRORTitle  = { fg = p.razor, bold = true },
    NotifyWARNTitle   = { fg = p.amber, bold = true },
    NotifyINFOTitle   = { fg = p.tech, bold = true },
    NotifyDEBUGTitle  = { fg = p.stealth, bold = true },
    NotifyTRACETitle  = { fg = p.sacred, bold = true },
    NotifyERRORBody   = { fg = p.text, bg = p.panel },
    NotifyWARNBody    = { fg = p.text, bg = p.panel },
    NotifyINFOBody    = { fg = p.text, bg = p.panel },
    NotifyDEBUGBody   = { fg = p.dim, bg = p.panel },
    NotifyTRACEBody   = { fg = p.dim, bg = p.panel },

    -- PLUGINS: SATELLITE (Scrollbar) -----------------------------------------
    SatelliteBar      = { bg = p.panel },
    SatelliteCursor   = { fg = p.razor },
    SatellitePosition = { fg = p.dim },
    SatelliteError    = { fg = p.alert },
    SatelliteWarning  = { fg = p.amber },
    SatelliteHint     = { fg = p.dim },
    SatelliteInfo     = { fg = p.tech },
    SatelliteSearch   = { fg = p.tech },
    SatelliteGit      = { fg = p.toxic },
    SatelliteMark     = { fg = p.amber },

    -- PLUGINS: OIL.NVIM (File Explorer) --------------------------------------
    OilDir            = { fg = p.tech, bold = true },
    OilDirIcon        = { fg = p.tech },
    OilLink           = { fg = p.sacred, italic = true },
    OilLinkTarget     = { fg = p.sacred },
    OilCopy           = { fg = p.amber, bold = true },
    OilMove           = { fg = p.amber },
    OilChange         = { fg = p.tech },
    OilCreate         = { fg = p.toxic, bold = true },
    OilDelete         = { fg = p.razor, bold = true },
    OilPermissionNone = { fg = p.stealth },
    OilPermissionRead = { fg = p.tech },
    OilPermissionWrite = { fg = p.amber },
    OilPermissionExecute = { fg = p.toxic },
    OilTypeDir        = { fg = p.tech },
    OilTypeFile       = { fg = p.text },
    OilTypeLink       = { fg = p.sacred },
    OilTypeSpecial    = { fg = p.razor },
    OilSize           = { fg = p.dim },
    OilMtime          = { fg = p.stealth },

    -- PLUGINS: NEOTEST --------------------------------------------------------
    NeotestPassed       = { fg = p.toxic },
    NeotestFailed       = { fg = p.razor },
    NeotestRunning      = { fg = p.amber },
    NeotestSkipped      = { fg = p.dim },
    NeotestUnknown      = { fg = p.stealth },
    NeotestTest         = { fg = p.text },
    NeotestFile         = { fg = p.tech },
    NeotestDir          = { fg = p.tech, bold = true },
    NeotestNamespace    = { fg = p.amber },
    NeotestMarked       = { fg = p.razor, bold = true },
    NeotestTarget       = { fg = p.razor },
    NeotestAdapterName  = { fg = p.sacred, bold = true },
    NeotestWinSelect    = { fg = p.tech, bold = true },
    NeotestFocused      = { bold = true },
    NeotestIndent       = { fg = p.border },
    NeotestExpandMarker = { fg = p.dim },
    NeotestWatching     = { fg = p.amber },

    -- PLUGINS: GRUG-FAR (Search & Replace) -----------------------------------
    GrugFarResultsHeader      = { fg = p.ink, bg = p.razor, bold = true },
    GrugFarResultsMatch       = { fg = p.void, bg = p.tech, bold = true },
    GrugFarResultsMatchAdded  = { fg = p.toxic },
    GrugFarResultsMatchRemoved = { fg = p.razor },
    GrugFarResultsLineNo      = { fg = p.dim },
    GrugFarResultsPath        = { fg = p.tech, underline = true },
    GrugFarResultsStats       = { fg = p.dim },
    GrugFarInputLabel         = { fg = p.amber, bold = true },
    GrugFarInputPlaceholder   = { fg = p.stealth },
    GrugFarHelpHeader         = { fg = p.dim, bold = true },
    GrugFarHelpWinHeader      = { fg = p.ink, bg = p.panel, bold = true },

    -- PLUGINS: TWINNY (AI Ghost Text) ----------------------------------------
    TwinnyAccept       = { fg = p.stealth, italic = true },
    TwinnyHint         = { fg = p.stealth, italic = true },

    -- PLUGINS: GITSIGNS (extended) -------------------------------------------
    GitSignsCurrentLineBlame  = { fg = p.stealth, italic = true },
    GitSignsAddNr             = { fg = p.toxic },
    GitSignsChangeNr          = { fg = p.tech },
    GitSignsDeleteNr          = { fg = p.razor },
    GitSignsAddLn             = { fg = p.toxic, bg = p.panel },
    GitSignsChangeLn          = { fg = p.tech, bg = p.panel },
    GitSignsDeleteLn          = { fg = p.razor, bg = p.panel },
    GitSignsAddPreview        = { fg = p.toxic, bg = p.panel },
    GitSignsDeletePreview     = { fg = p.razor, bg = p.panel },
    GitSignsAddInline         = { fg = p.void, bg = p.toxic },
    GitSignsDeleteInline      = { fg = p.void, bg = p.razor },
    GitSignsChangeInline      = { fg = p.void, bg = p.tech },
    GitSignsUntracked         = { fg = p.dim },

    -- PLUGINS: RENDER-MARKDOWN ------------------------------------------------
    RenderMarkdownH1         = { fg = p.razor, bold = true },
    RenderMarkdownH2         = { fg = p.amber, bold = true },
    RenderMarkdownH3         = { fg = p.tech, bold = true },
    RenderMarkdownH4         = { fg = p.toxic, bold = true },
    RenderMarkdownH5         = { fg = p.sacred, bold = true },
    RenderMarkdownH6         = { fg = p.azure, bold = true },
    RenderMarkdownH1Bg       = { bg = p.panel },
    RenderMarkdownH2Bg       = { bg = p.panel },
    RenderMarkdownH3Bg       = { bg = p.panel },
    RenderMarkdownH4Bg       = { bg = p.panel },
    RenderMarkdownH5Bg       = { bg = p.panel },
    RenderMarkdownH6Bg       = { bg = p.panel },
    RenderMarkdownCode       = { bg = p.panel },
    RenderMarkdownCodeInline = { fg = p.toxic, bg = p.panel },
    RenderMarkdownBullet     = { fg = p.razor },
    RenderMarkdownQuote      = { fg = p.stealth, italic = true },
    RenderMarkdownDash       = { fg = p.border },
    RenderMarkdownLink       = { fg = p.tech, underline = true },
    RenderMarkdownSign       = { bg = p.void },
    RenderMarkdownMath       = { fg = p.tech },
    RenderMarkdownTableHead  = { fg = p.ink, bg = p.razor, bold = true },
    RenderMarkdownTableRow   = { fg = p.text },
    RenderMarkdownTableFill  = { fg = p.border },
    RenderMarkdownTodo       = { fg = p.void, bg = p.amber, bold = true },
    RenderMarkdownUnchecked  = { fg = p.stealth },
    RenderMarkdownChecked    = { fg = p.toxic },
  }

  for group, highlight in pairs(groups) do
    vim.api.nvim_set_hl(0, group, highlight)
  end

  local links = {
    ["@annotation"] = "Special",
    ["@attribute"] = "Special",
    ["@character"] = "Character",
    ["@comment"] = "Comment",
    ["@constant"] = "Constant",
    ["@constant.builtin"] = "Constant",
    ["@constant.macro"] = "Macro",
    ["@constructor"] = "Type",
    ["@debug"] = "Debug",
    ["@define"] = "Define",
    ["@exception"] = "Exception",
    ["@field"] = "Identifier",
    ["@float"] = "Float",
    ["@function"] = "Function",
    ["@function.builtin"] = "Function",
    ["@function.call"] = "Function",
    ["@function.macro"] = "Macro",
    ["@include"] = "Include",
    ["@keyword"] = "Keyword",
    ["@keyword.function"] = "Keyword",
    ["@keyword.operator"] = "Operator",
    ["@keyword.return"] = "Keyword",
    ["@label"] = "Label",
    ["@method"] = "Function",
    ["@method.call"] = "Function",
    ["@module"] = "Structure",
    ["@namespace"] = "Structure",
    ["@number"] = "Number",
    ["@operator"] = "Operator",
    ["@parameter"] = "Identifier",
    ["@preproc"] = "PreProc",
    ["@property"] = "Identifier",
    ["@punctuation"] = "Delimiter",
    ["@punctuation.bracket"] = "Delimiter",
    ["@punctuation.delimiter"] = "Delimiter",
    ["@punctuation.special"] = "Delimiter",
    ["@repeat"] = "Repeat",
    ["@string"] = "String",
    ["@string.escape"] = "SpecialChar",
    ["@string.regex"] = "SpecialChar",
    ["@string.special"] = "SpecialChar",
    ["@tag"] = "Tag",
    ["@tag.attribute"] = "Identifier",
    ["@tag.delimiter"] = "Delimiter",
    ["@text"] = "Normal",
    ["@text.title"] = "Title",
    ["@markup.heading"] = "Title",
    ["@markup.heading.1"] = "Title",
    ["@markup.heading.2"] = "Title",
    ["@markup.heading.3"] = "Title",
    ["@markup.heading.4"] = "Title",
    ["@markup.heading.5"] = "Title",
    ["@markup.heading.6"] = "Title",
    ["@markup.link"] = "ApexMarkupLink",
    ["@markup.link.label"] = "ApexMarkupLink",
    ["@markup.link.url"] = "ApexMarkupLink",
    ["@markup.strong"] = "ApexMarkupStrong",
    ["@markup.italic"] = "ApexMarkupItalic",
    ["@markup.strikethrough"] = "DiagnosticDeprecated",
    ["@markup.underline"] = "Underlined",
    ["@markup.raw"] = "String",
    ["@markup.raw.block"] = "String",
    ["@markup.raw.delimiter"] = "Delimiter",
    ["@markup.quote"] = "Comment",
    ["@markup.list"] = "Delimiter",
    ["@markup.list.checked"] = "String",
    ["@markup.list.unchecked"] = "Comment",
    ["@markup.math"] = "Constant",
    ["@markup.environment"] = "Type",
    ["@markup.environment.name"] = "Type",
    ["@type"] = "Type",
    ["@type.builtin"] = "Type",
    ["@type.definition"] = "Type",
    ["@type.qualifier"] = "Keyword",
    ["@variable"] = "Identifier",
    ["@variable.builtin"] = "Identifier",

    ["@lsp.type.boolean"] = "Boolean",
    ["@lsp.type.builtinType"] = "Type",
    ["@lsp.type.class"] = "Type",
    ["@lsp.type.comment"] = "Comment",
    ["@lsp.type.decorator"] = "Special",
    ["@lsp.type.enum"] = "Type",
    ["@lsp.type.enumMember"] = "Constant",
    ["@lsp.type.event"] = "Type",
    ["@lsp.type.function"] = "Function",
    ["@lsp.type.interface"] = "Type",
    ["@lsp.type.keyword"] = "Keyword",
    ["@lsp.type.macro"] = "Macro",
    ["@lsp.type.method"] = "Function",
    ["@lsp.type.modifier"] = "Keyword",
    ["@lsp.type.namespace"] = "Structure",
    ["@lsp.type.number"] = "Number",
    ["@lsp.type.operator"] = "Operator",
    ["@lsp.type.parameter"] = "Identifier",
    ["@lsp.type.property"] = "Identifier",
    ["@lsp.type.regexp"] = "SpecialChar",
    ["@lsp.type.string"] = "String",
    ["@lsp.type.struct"] = "Structure",
    ["@lsp.type.type"] = "Type",
    ["@lsp.type.typeParameter"] = "Type",
    ["@lsp.type.variable"] = "Identifier",

    ["@lsp.mod.deprecated"] = "DiagnosticDeprecated",
    ["@lsp.mod.abstract"] = "Type",
    ["@lsp.mod.declaration"] = "Keyword",
    ["@lsp.mod.defaultLibrary"] = "Constant",
    ["@lsp.mod.definition"] = "Keyword",
    ["@lsp.mod.documentation"] = "Comment",
    ["@lsp.mod.modification"] = "Operator",
    ["@lsp.mod.readonly"] = "Constant",
    ["@lsp.mod.static"] = "Constant",
    ["@lsp.mod.async"] = "Keyword",

    ["@lsp.typemod.function.async"] = "Keyword",
    ["@lsp.typemod.method.async"] = "Keyword",
    ["@lsp.typemod.function.deprecated"] = "DiagnosticDeprecated",
    ["@lsp.typemod.method.deprecated"] = "DiagnosticDeprecated",
    ["@lsp.typemod.variable.deprecated"] = "DiagnosticDeprecated",
    ["@lsp.typemod.variable.readonly"] = "Constant",
    ["@lsp.typemod.parameter.readonly"] = "Constant",
    ["@lsp.typemod.property.readonly"] = "Constant",
    ["@lsp.typemod.variable.static"] = "Constant",
    ["@lsp.typemod.property.static"] = "Constant",
  }

  for group, target in pairs(links) do
    vim.api.nvim_set_hl(0, group, { link = target })
  end
end

M.load()

-- PLUGINS: LUALINE --------------------------------------------------------
-- Export lualine theme from palette for use in lualine config
do
  local p = M.palette
  M.lualine = {
    normal = {
      a = { fg = p.ink, bg = p.razor, gui = "bold" },
      b = { fg = p.text, bg = p.panel },
      c = { fg = p.dim, bg = p.void },
    },
    insert = {
      a = { fg = p.ink, bg = p.toxic, gui = "bold" },
      b = { fg = p.text, bg = p.panel },
      c = { fg = p.dim, bg = p.void },
    },
    visual = {
      a = { fg = p.ink, bg = p.tech, gui = "bold" },
      b = { fg = p.text, bg = p.panel },
      c = { fg = p.dim, bg = p.void },
    },
    replace = {
      a = { fg = p.ink, bg = p.amber, gui = "bold" },
      b = { fg = p.text, bg = p.panel },
      c = { fg = p.dim, bg = p.void },
    },
    command = {
      a = { fg = p.ink, bg = p.sacred, gui = "bold" },
      b = { fg = p.text, bg = p.panel },
      c = { fg = p.dim, bg = p.void },
    },
    inactive = {
      a = { fg = p.dim, bg = p.panel },
      b = { fg = p.dim, bg = p.panel },
      c = { fg = p.dim, bg = p.void },
    },
  }
end

return M