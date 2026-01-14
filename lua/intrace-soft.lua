-- intrace-soft: reduced contrast variant of intrace
-- Same aesthetic vibe, easier on the eyes

local C = {
  bg        = "#121215",         -- lifted from near-black, slight cool tint
  surface   = "#18181b",         -- softer surface
  border    = "#27272a",         -- more visible borders
  fg        = "#d4d4d8",         -- soft off-white (zinc-300)
  muted     = "#71717a",         -- zinc-500
  comment   = "#5a8a9e",         -- softer muted cyan for comments
  docstring = "#4d7a8a",         -- cooler hue for docstrings
  red       = "#c53030",         -- softer red
  red_b     = "#c47070",         -- muted red
  red_light = "#e8b4b4",         -- softer light red for highlights
  amber     = "#d99a06",         -- softer amber
  green     = "#3fbb5e",         -- softer green
  green_b   = "#54c872",         -- softer bright green
  yellow    = "#c49800",         -- softer yellow
  yellow_b  = "#d4ab18",         -- softer bright yellow
  blue      = "#3574d4",         -- softer blue
  purple    = "#5f34a8",         -- softer purple
  purple_b  = "#7348c0",         -- softer bright purple
  cyan      = "#20bdd6",         -- softer cyan
  cyan_dim  = "#5cd0e0",         -- softer dim cyan
  orange    = "#9e2c2c",         -- softer orange-red
  orange_b  = "#bb4040",         -- softer bright orange
  brown     = "#6b5232",         -- softer brown
  brown_b   = "#8a6a44",         -- softer bright brown
  white_d   = "#c8c8cc",         -- soft white
  punct_dim = "#4a4a50",         -- slightly lifted punctuation
  param     = "#9580e0",         -- softer parameter purple
}

local function hi(group, opts) vim.api.nvim_set_hl(0, group, opts) end

local M = {}
function M.load()
  vim.o.termguicolors = true
  vim.o.background = "dark"

  hi("Normal",         { fg=C.fg, bg=C.bg })
  hi("NormalNC",       { fg=C.fg, bg=C.bg })
  hi("NormalFloat",    { fg=C.fg, bg=C.surface })
  hi("FloatBorder",    { fg=C.brown_b, bg=C.surface })
  hi("WinSeparator",   { fg=C.border })
  hi("VertSplit",      { fg=C.border })
  hi("LineNr",         { fg=C.muted, bg=C.bg })
  hi("CursorLine",     { bg="#16161a" })
  hi("CursorLineNr",   { fg=C.yellow_b, bold=true })
  hi("SignColumn",     { bg=C.bg })
  hi("StatusLine",     { fg=C.white_d, bg="#1a1a1e" })
  hi("StatusLineNC",   { fg=C.muted, bg="#151518" })
  hi("Pmenu",          { fg=C.white_d, bg="#1a1a1e" })
  hi("PmenuSel",       { fg=C.bg, bg=C.orange_b, bold=true })
  hi("PmenuThumb",     { bg=C.border })
  hi("Visual",         { bg="#252830" })            -- softer teal-tinted selection
  hi("Search",         { fg=C.bg, bg=C.red_light, bold=true })
  hi("IncSearch",      { fg=C.bg, bg=C.orange_b, bold=true })
  hi("MatchParen",     { fg=C.cyan, bg="#252525", bold=true })
  hi("Whitespace",     { fg=C.border })
  hi("NonText",        { fg=C.border })
  hi("Comment",        { fg=C.comment, italic=true })
  hi("Todo",           { fg=C.bg, bg=C.purple_b, bold=true })
  hi("Title",          { fg=C.white_d, bold=true })

  -- Syntax
  hi("Constant",       { fg=C.orange_b })
  hi("String",         { fg=C.green })
  hi("Number",         { fg=C.yellow_b })
  hi("Boolean",        { fg=C.purple_b })
  hi("Identifier",     { fg=C.white_d })
  hi("Function",       { fg=C.orange_b, bold=true })
  hi("Statement",      { fg=C.purple })
  hi("Conditional",    { fg=C.purple_b })
  hi("Repeat",         { fg=C.purple_b })
  hi("Operator",       { fg=C.muted })
  hi("Keyword",        { fg=C.purple })
  hi("Include",        { fg=C.purple })
  hi("PreProc",        { fg=C.orange })
  hi("Type",           { fg=C.cyan })
  hi("Special",        { fg=C.red_b })
  hi("Delimiter",      { fg=C.punct_dim })
  hi("Error",          { fg=C.bg, bg=C.red })
  hi("WarningMsg",     { fg=C.amber })
  hi("MoreMsg",        { fg=C.green_b })
  hi("Question",       { fg=C.green_b })

  -- Diagnostics (colorblind-safe)
  hi("DiagnosticError",{ fg=C.red })
  hi("DiagnosticWarn", { fg=C.amber })
  hi("DiagnosticInfo", { fg=C.blue })
  hi("DiagnosticHint", { fg=C.cyan_dim })
  hi("DiagnosticUnderlineError", { underline=true, sp=C.red })
  hi("DiagnosticUnderlineWarn",  { underline=true, sp=C.amber })
  hi("DiagnosticUnderlineInfo",  { underline=true, sp=C.blue })
  hi("DiagnosticUnderlineHint",  { underline=true, sp=C.cyan_dim })
  hi("LspReferenceText",  { bg="#1a1a1e" })
  hi("LspReferenceRead",  { bg="#1a1a1e" })
  hi("LspReferenceWrite", { bg="#1a1a1e" })

  -- Git
  hi("DiffAdd",        { fg=C.green_b, bg="#101812" })
  hi("DiffChange",     { fg=C.yellow_b, bg="#18160c" })
  hi("DiffDelete",     { fg=C.red_b, bg="#1a1010" })
  hi("DiffText",       { fg=C.orange_b, bg="#201810" })
  hi("GitSignsAdd",    { fg=C.green })
  hi("GitSignsChange", { fg=C.yellow })
  hi("GitSignsDelete", { fg=C.red })

  -- Telescope
  hi("TelescopeNormal",{ fg=C.white_d, bg=C.surface })
  hi("TelescopeBorder",{ fg=C.border,  bg=C.surface })
  hi("TelescopeSelection", { fg=C.bg, bg=C.orange_b, bold=true })
  hi("TelescopeMatching", { fg=C.red_light, bold=true })
  hi("TelescopePromptPrefix", { fg=C.orange_b })

  -- Blink.cmp completion menu
  hi("BlinkCmpMenu", { fg=C.white_d, bg="#1a1a1e" })
  hi("BlinkCmpMenuSelection", { fg=C.bg, bg=C.orange_b, bold=true })
  hi("BlinkCmpLabel", { fg=C.white_d })
  hi("BlinkCmpLabelMatch", { fg=C.red_light, bold=true })
  hi("BlinkCmpKind", { fg=C.orange_b })

  -- Neo-tree common groups
  hi("Directory",      { fg=C.yellow_b })
  hi("ErrorMsg",       { fg=C.red_b })

  -- WhichKey
  hi("WhichKey",       { fg=C.purple_b })
  hi("WhichKeyGroup",  { fg=C.orange_b })
  hi("WhichKeyDesc",   { fg=C.white_d })

  -- Floating UI borders
  hi("FloatTitle",     { fg=C.orange_b, bg=C.surface, bold=true })

  -- Indent guides
  hi("IblIndent",      { fg="#1e1e22" })            -- subtle indent guides
  hi("IblScope",       { fg="#303035" })            -- active scope guide

  -- Python-specific (Treesitter)
  hi("@string.documentation.python", { fg=C.docstring, italic=true })
  hi("@function.builtin.python",     { fg=C.green_b })
  hi("@variable.builtin.python",     { fg=C.purple_b })
  hi("@constant.builtin.python",     { fg=C.purple_b })
  hi("@keyword.function.python",     { fg=C.purple_b, bold=true })
  hi("@keyword.type.python",         { fg=C.purple_b, bold=true })
  hi("@function.python",             { fg=C.orange_b, bold=true })
  hi("@type.python",                 { fg=C.cyan })
  hi("@variable.parameter.python",   { fg=C.param })
  hi("@punctuation.special.python",  { fg=C.orange })
  hi("@decorator.python",            { fg=C.brown_b, bold=true })
  hi("@string.escape.python",        { fg=C.cyan })

  -- TypeScript/JavaScript (Treesitter)
  hi("@type.typescript",             { fg=C.cyan })
  hi("@type.builtin.typescript",     { fg=C.cyan_dim })
  hi("@variable.parameter",          { fg=C.param })
  hi("@variable.member",             { fg=C.white_d })
  hi("@keyword.type",                { fg=C.purple_b })
  hi("@constructor",                 { fg=C.yellow, bold=true })

  -- LSP semantic tokens
  hi("@lsp.type.parameter",          { fg=C.param })
  hi("@lsp.type.variable",           { fg=C.white_d })
  hi("@lsp.type.property",           { fg=C.white_d })
  hi("@lsp.type.type",               { fg=C.cyan })
  hi("@lsp.type.class",              { fg=C.yellow, bold=true })
  hi("@lsp.type.interface",          { fg=C.cyan, bold=true })
  hi("@lsp.type.decorator",          { fg=C.brown_b, bold=true })
  hi("@lsp.type.function",           { fg=C.orange_b, bold=true })

  -- General Treesitter enhancements
  hi("@punctuation.bracket",         { fg=C.punct_dim })
  hi("@punctuation.delimiter",       { fg=C.punct_dim })
end

return M
