-- intrace-black: pure black variant of intrace
-- Battery saving / OLED optimized - cutting-edge minimalist aesthetic

local C = {
  bg        = "#000000",         -- pure black for OLED
  surface   = "#0a0a0a",         -- subtle surface lift
  border    = "#1a1a1a",         -- minimal borders
  fg        = "#ffffff",         -- pure white text
  muted     = "#888888",         -- muted gray
  comment   = "#6b9fb5",         -- muted cyan for comments
  docstring = "#5a8fa3",         -- cooler hue for docstrings
  red       = "#dc2626",         -- red-600 colorblind-safe
  red_b     = "#d86868",         -- muted red
  red_light = "#f5a5a5",         -- super light red for text highlights
  amber     = "#f59e0b",         -- amber-500 colorblind-safe
  green     = "#49d36d",         -- vibrant green
  green_b   = "#60e185",         -- bright green
  yellow    = "#d6a800",         -- yellow
  yellow_b  = "#e9bf1a",         -- bright yellow
  blue      = "#3b82f6",         -- blue-500 colorblind-safe
  purple    = "#6e3ac2",         -- purple
  purple_b  = "#8350d8",         -- bright purple
  cyan      = "#22d3ee",         -- cyan-400 for types
  cyan_dim  = "#67e8f9",         -- cyan-300 dimmer
  orange    = "#b43232",         -- orange-red
  orange_b  = "#d24747",         -- bright orange
  brown     = "#7a5f3a",         -- brown
  brown_b   = "#9b7a4d",         -- bright brown
  white_d   = "#e6e6e6",         -- soft white
  punct_dim = "#555555",         -- dimmed punctuation
  param     = "#a78bfa",         -- purple-400 for parameters
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
  hi("CursorLine",     { bg="#050505" })
  hi("CursorLineNr",   { fg=C.yellow_b, bold=true })
  hi("SignColumn",     { bg=C.bg })
  hi("StatusLine",     { fg=C.white_d, bg="#0a0a0a" })
  hi("StatusLineNC",   { fg=C.muted, bg="#050505" })
  hi("Pmenu",          { fg=C.white_d, bg="#0a0a0a" })
  hi("PmenuSel",       { fg=C.bg, bg=C.orange_b, bold=true })
  hi("PmenuThumb",     { bg=C.border })
  hi("Visual",         { bg="#1e2a2e" })            -- teal-tinted selection
  hi("Search",         { fg=C.bg, bg=C.red_light, bold=true })
  hi("IncSearch",      { fg=C.bg, bg=C.orange_b, bold=true })
  hi("MatchParen",     { fg=C.cyan, bg="#1a1a1a", bold=true })
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
  hi("LspReferenceText",  { bg="#0a0a0a" })
  hi("LspReferenceRead",  { bg="#0a0a0a" })
  hi("LspReferenceWrite", { bg="#0a0a0a" })

  -- Git
  hi("DiffAdd",        { fg=C.green_b, bg="#051208" })
  hi("DiffChange",     { fg=C.yellow_b, bg="#100e03" })
  hi("DiffDelete",     { fg=C.red_b, bg="#120505" })
  hi("DiffText",       { fg=C.orange_b, bg="#150a04" })
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
  hi("BlinkCmpMenu", { fg=C.white_d, bg="#0a0a0a" })
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
  hi("IblIndent",      { fg="#0a0a0a" })            -- minimal indent guides
  hi("IblScope",       { fg="#1a1a1a" })            -- subtle active scope guide

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
