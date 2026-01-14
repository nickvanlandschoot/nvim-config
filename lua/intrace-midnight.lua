-- intrace-midnight: midnight blue variant of intrace
-- Calm & sophisticated with subtle blue tint throughout

local C = {
  bg        = "#10141d",         -- deep midnight blue
  surface   = "#151925",         -- slightly lighter surface
  border    = "#1e2536",         -- blue-tinted borders
  fg        = "#e8eaed",         -- soft off-white
  muted     = "#7c8395",         -- blue-gray muted
  comment   = "#5b8fb0",         -- cool muted cyan for comments
  docstring = "#4a7d9a",         -- deeper cool hue for docstrings
  red       = "#e74c5c",         -- softer red with blue undertone
  red_b     = "#e77d88",         -- muted red
  red_light = "#f0b3ba",         -- soft light red for highlights
  amber     = "#e6a94f",         -- warmer amber
  green     = "#45c275",         -- cooler green
  green_b   = "#5dd490",         -- bright green
  yellow    = "#d4ad3f",         -- warmer yellow
  yellow_b  = "#e8c252",         -- bright yellow
  blue      = "#4d8fd9",         -- cool blue
  purple    = "#7554d4",         -- cooler purple
  purple_b  = "#906fe0",         -- bright purple
  cyan      = "#2ec9e8",         -- vibrant cyan
  cyan_dim  = "#6dd7ed",         -- dimmer cyan
  orange    = "#c05045",         -- cooler orange-red
  orange_b  = "#d8685c",         -- bright orange
  brown     = "#8a7250",         -- cooler brown
  brown_b   = "#a58d66",         -- bright brown
  white_d   = "#d0d3d8",         -- soft white
  punct_dim = "#4a5163",         -- blue-tinted punctuation
  param     = "#a991f2",         -- cooler parameter purple
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
  hi("CursorLine",     { bg="#141823" })
  hi("CursorLineNr",   { fg=C.yellow_b, bold=true })
  hi("SignColumn",     { bg=C.bg })
  hi("StatusLine",     { fg=C.white_d, bg="#181c28" })
  hi("StatusLineNC",   { fg=C.muted, bg="#131720" })
  hi("Pmenu",          { fg=C.white_d, bg="#181c28" })
  hi("PmenuSel",       { fg=C.bg, bg=C.orange_b, bold=true })
  hi("PmenuThumb",     { bg=C.border })
  hi("Visual",         { bg="#1a2838" })            -- blue-tinted selection
  hi("Search",         { fg=C.bg, bg=C.red_light, bold=true })
  hi("IncSearch",      { fg=C.bg, bg=C.orange_b, bold=true })
  hi("MatchParen",     { fg=C.cyan, bg="#1e2536", bold=true })
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
  hi("LspReferenceText",  { bg="#181c28" })
  hi("LspReferenceRead",  { bg="#181c28" })
  hi("LspReferenceWrite", { bg="#181c28" })

  -- Git
  hi("DiffAdd",        { fg=C.green_b, bg="#0e1a16" })
  hi("DiffChange",     { fg=C.yellow_b, bg="#181410" })
  hi("DiffDelete",     { fg=C.red_b, bg="#1a1214" })
  hi("DiffText",       { fg=C.orange_b, bg="#1f1612" })
  hi("GitSignsAdd",    { fg=C.green })
  hi("GitSignsChange", { fg=C.yellow })
  hi("GitSignsDelete", { fg=C.red })

  -- Telescope
  hi("TelescopeNormal",{ fg=C.white_d, bg=C.surface })
  hi("TelescopeBorder",{ fg=C.border, bg=C.surface })
  hi("TelescopeSelection", { fg=C.bg, bg=C.orange_b, bold=true })
  hi("TelescopeMatching", { fg=C.red_light, bold=true })
  hi("TelescopePromptPrefix", { fg=C.orange_b })

  -- Blink.cmp completion menu
  hi("BlinkCmpMenu", { fg=C.white_d, bg="#181c28" })
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
  hi("IblIndent",      { fg="#1a1e2a" })            -- subtle indent guides
  hi("IblScope",       { fg="#2a2f3e" })            -- active scope guide

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
