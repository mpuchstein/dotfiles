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

return M