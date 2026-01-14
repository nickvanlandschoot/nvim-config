-- intrace-light: light mode variant of intrace
-- Proves mastery of color theory by being comfortable on bright backgrounds

local C = {
  bg        = "#f8f9fa",         -- light gray background
  surface   = "#ffffff",         -- pure white for surfaces
  border    = "#dee2e6",         -- subtle borders
  fg        = "#212529",         -- dark text
  muted     = "#6c757d",         -- muted gray for secondary text
  comment   = "#0077aa",         -- darker cyan for comments (readable)
  docstring = "#006688",         -- deeper cyan for docstrings
  red       = "#c92a2a",         -- vibrant red
  red_b     = "#e03131",         -- bright red
  red_light = "#ffc9c9",         -- light red for highlights
  amber     = "#d9770b",         -- darker amber for visibility
  green     = "#2f9e44",         -- darker green for readability
  green_b   = "#37b24d",         -- bright green
  yellow    = "#c49800",         -- darker yellow
  yellow_b  = "#fcc419",         -- bright yellow
  blue      = "#1971c2",         -- darker blue for readability
  purple    = "#7048e8",         -- vibrant purple
  purple_b  = "#9775fa",         -- bright purple
  cyan      = "#0c8599",         -- darker cyan for readability
  cyan_dim  = "#3bc9db",         -- lighter cyan
  orange    = "#c2410c",         -- darker orange-red for visibility
  orange_b  = "#d84a1b",         -- bright orange
  brown     = "#8b5a3c",         -- darker brown
  brown_b   = "#a06e4a",         -- bright brown
  white_d   = "#495057",         -- dark gray (inverted white)
  punct_dim = "#adb5bd",         -- dimmed punctuation
  param     = "#7950f2",         -- purple for parameters
}

local function hi(group, opts) vim.api.nvim_set_hl(0, group, opts) end

local M = {}
function M.load()
  vim.o.termguicolors = true
  vim.o.background = "light"

  hi("Normal",         { fg=C.fg, bg=C.bg })
  hi("NormalNC",       { fg=C.fg, bg=C.bg })
  hi("NormalFloat",    { fg=C.fg, bg=C.surface })
  hi("FloatBorder",    { fg=C.brown_b, bg=C.surface })
  hi("WinSeparator",   { fg=C.border })
  hi("VertSplit",      { fg=C.border })
  hi("LineNr",         { fg=C.muted, bg=C.bg })
  hi("CursorLine",     { bg="#f1f3f5" })
  hi("CursorLineNr",   { fg=C.orange_b, bold=true })
  hi("SignColumn",     { bg=C.bg })
  hi("StatusLine",     { fg=C.fg, bg="#e9ecef" })
  hi("StatusLineNC",   { fg=C.muted, bg="#f1f3f5" })
  hi("Pmenu",          { fg=C.fg, bg="#e9ecef" })
  hi("PmenuSel",       { fg=C.surface, bg=C.orange_b, bold=true })
  hi("PmenuThumb",     { bg=C.border })
  hi("Visual",         { bg="#d0ebff" })            -- light blue selection
  hi("Search",         { fg=C.fg, bg="#ffd8a8", bold=true })
  hi("IncSearch",      { fg=C.surface, bg=C.orange_b, bold=true })
  hi("MatchParen",     { fg=C.cyan, bg="#e9ecef", bold=true })
  hi("Whitespace",     { fg=C.border })
  hi("NonText",        { fg=C.border })
  hi("Comment",        { fg=C.comment, italic=true })
  hi("Todo",           { fg=C.surface, bg=C.purple_b, bold=true })
  hi("Title",          { fg=C.fg, bold=true })

  -- Syntax
  hi("Constant",       { fg=C.orange_b })
  hi("String",         { fg=C.green })
  hi("Number",         { fg=C.yellow })
  hi("Boolean",        { fg=C.purple_b })
  hi("Identifier",     { fg=C.fg })
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
  hi("Error",          { fg=C.surface, bg=C.red })
  hi("WarningMsg",     { fg=C.amber })
  hi("MoreMsg",        { fg=C.green_b })
  hi("Question",       { fg=C.green_b })

  -- Diagnostics (colorblind-safe)
  hi("DiagnosticError",{ fg=C.red })
  hi("DiagnosticWarn", { fg=C.amber })
  hi("DiagnosticInfo", { fg=C.blue })
  hi("DiagnosticHint", { fg=C.cyan })
  hi("DiagnosticUnderlineError", { underline=true, sp=C.red })
  hi("DiagnosticUnderlineWarn",  { underline=true, sp=C.amber })
  hi("DiagnosticUnderlineInfo",  { underline=true, sp=C.blue })
  hi("DiagnosticUnderlineHint",  { underline=true, sp=C.cyan })
  hi("LspReferenceText",  { bg="#e9ecef" })
  hi("LspReferenceRead",  { bg="#e9ecef" })
  hi("LspReferenceWrite", { bg="#e9ecef" })

  -- Git
  hi("DiffAdd",        { fg=C.green_b, bg="#d3f9d8" })
  hi("DiffChange",     { fg=C.yellow_b, bg="#fff3bf" })
  hi("DiffDelete",     { fg=C.red_b, bg="#ffe3e3" })
  hi("DiffText",       { fg=C.orange_b, bg="#ffd8a8" })
  hi("GitSignsAdd",    { fg=C.green })
  hi("GitSignsChange", { fg=C.yellow })
  hi("GitSignsDelete", { fg=C.red })

  -- Telescope
  hi("TelescopeNormal",{ fg=C.fg, bg=C.surface })
  hi("TelescopeBorder",{ fg=C.border, bg=C.surface })
  hi("TelescopeSelection", { fg=C.surface, bg=C.orange_b, bold=true })
  hi("TelescopeMatching", { fg=C.orange, bold=true })
  hi("TelescopePromptPrefix", { fg=C.orange_b })

  -- Blink.cmp completion menu
  hi("BlinkCmpMenu", { fg=C.fg, bg="#e9ecef" })
  hi("BlinkCmpMenuSelection", { fg=C.surface, bg=C.orange_b, bold=true })
  hi("BlinkCmpLabel", { fg=C.fg })
  hi("BlinkCmpLabelMatch", { fg=C.orange, bold=true })
  hi("BlinkCmpKind", { fg=C.orange_b })

  -- Neo-tree common groups
  hi("Directory",      { fg=C.yellow })
  hi("ErrorMsg",       { fg=C.red_b })

  -- WhichKey
  hi("WhichKey",       { fg=C.purple_b })
  hi("WhichKeyGroup",  { fg=C.orange_b })
  hi("WhichKeyDesc",   { fg=C.fg })

  -- Floating UI borders
  hi("FloatTitle",     { fg=C.orange_b, bg=C.surface, bold=true })

  -- Indent guides
  hi("IblIndent",      { fg="#e9ecef" })            -- subtle indent guides
  hi("IblScope",       { fg="#dee2e6" })            -- active scope guide

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
  hi("@variable.member",             { fg=C.fg })
  hi("@keyword.type",                { fg=C.purple_b })
  hi("@constructor",                 { fg=C.yellow, bold=true })

  -- LSP semantic tokens
  hi("@lsp.type.parameter",          { fg=C.param })
  hi("@lsp.type.variable",           { fg=C.fg })
  hi("@lsp.type.property",           { fg=C.fg })
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
