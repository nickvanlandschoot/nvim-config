-- intrace-muted: muted color variant of intrace
-- Reduced saturation and contrast for comfortable extended coding sessions

local C = {
  bg        = "#1a1a1d",         -- significantly lifted background, warm gray tint
  surface   = "#202023",         -- softer surface with more separation
  border    = "#2d2d32",         -- more visible borders for clarity
  fg        = "#c4c4c8",         -- muted off-white (zinc-200)
  muted     = "#7d7d85",         -- zinc-400 - more visible muted text
  comment   = "#6a8fa0",         -- muted cyan for comments
  docstring = "#5d7f8d",         -- cooler hue for docstrings
  red       = "#b83a3a",         -- muted red
  red_b     = "#b86a6a",         -- muted red
  red_light = "#e0b8b8",         -- muted light red for highlights
  amber     = "#c98a06",         -- muted amber
  green     = "#3aab5a",         -- muted green
  green_b   = "#4db868",         -- muted bright green
  yellow    = "#b88800",         -- muted yellow
  yellow_b  = "#c99a18",         -- muted bright yellow
  blue      = "#3264c4",         -- muted blue
  purple    = "#5a2ea0",         -- muted purple
  purple_b  = "#6d38b8",         -- muted bright purple
  cyan      = "#1dadc6",         -- muted cyan
  cyan_dim  = "#54c0d0",         -- muted dim cyan
  orange    = "#942c2c",         -- muted orange-red
  orange_b  = "#ab3838",         -- muted bright orange
  brown     = "#654a2a",         -- muted brown
  brown_b   = "#7e5e3c",         -- muted bright brown
  white_d   = "#b8b8bc",         -- muted white
  punct_dim = "#525258",         -- more visible punctuation
  param     = "#8d70d0",         -- muted parameter purple
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
  hi("CursorLine",     { bg="#1e1e22" })            -- muted cursor line
  hi("CursorLineNr",   { fg=C.yellow_b, bold=true })
  hi("SignColumn",     { bg=C.bg })
  hi("StatusLine",     { fg=C.white_d, bg=C.bg })
  hi("StatusLineNC",   { fg=C.muted, bg=C.bg })
  hi("Pmenu",          { fg=C.white_d, bg=C.bg })
  hi("PmenuSel",       { fg=C.bg, bg=C.orange_b, bold=true })
  hi("PmenuThumb",     { bg=C.border })
  hi("Visual",         { bg="#2d3035" })            -- muted selection
  hi("Search",         { fg=C.bg, bg=C.red_light, bold=true })
  hi("IncSearch",      { fg=C.bg, bg=C.orange_b, bold=true })
  hi("MatchParen",     { fg=C.cyan, bg="#2d2d32", bold=true })
  hi("Whitespace",     { fg=C.border })
  hi("NonText",        { fg=C.border })
  hi("EndOfBuffer",    { fg=C.bg, bg=C.bg })       -- seamless background continuation
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
  hi("DiagnosticError", { fg=C.red })
  hi("DiagnosticWarn", { fg=C.amber })
  hi("DiagnosticInfo", { fg=C.blue })
  hi("DiagnosticHint", { fg=C.cyan_dim })
  hi("DiagnosticUnderlineError", { underline=true, sp=C.red })
  hi("DiagnosticUnderlineWarn",  { underline=true, sp=C.amber })
  hi("DiagnosticUnderlineInfo",  { underline=true, sp=C.blue })
  hi("DiagnosticUnderlineHint",  { underline=true, sp=C.cyan_dim })
  hi("LspReferenceText",  { bg=C.bg })
  hi("LspReferenceRead",  { bg=C.bg })
  hi("LspReferenceWrite", { bg=C.bg })

  -- Git
  hi("DiffAdd",        { fg=C.green_b, bg="#141a16" })
  hi("DiffChange",     { fg=C.yellow_b, bg="#1a1810" })
  hi("DiffDelete",     { fg=C.red_b, bg="#1c1414" })
  hi("DiffText",       { fg=C.orange_b, bg="#221c14" })
  hi("GitSignsAdd",    { fg=C.green })
  hi("GitSignsChange", { fg=C.yellow })
  hi("GitSignsDelete", { fg=C.red })

  -- Telescope
  hi("TelescopeNormal", { fg=C.white_d, bg=C.surface })
  hi("TelescopeBorder", { fg=C.border, bg=C.surface })
  hi("TelescopeSelection", { fg=C.bg, bg=C.orange_b, bold=true })
  hi("TelescopeMatching", { fg=C.red_light, bold=true })
  hi("TelescopePromptPrefix", { fg=C.orange_b })

  -- Blink.cmp completion menu
  hi("BlinkCmpMenu", { fg=C.white_d, bg=C.bg })
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
  hi("IblIndent",      { fg="#252529" })            -- muted indent guides
  hi("IblScope",       { fg="#35353a" })            -- active scope guide

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
