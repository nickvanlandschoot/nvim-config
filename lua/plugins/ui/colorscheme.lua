local C = {
  bg        = "#0a0a0a",
  surface   = "#0f0f0f",
  border    = "#1a1a1a",
  fg        = "#ffffff",
  muted     = "#888888",
  comment   = "#6b9fb5",        -- muted cyan for comments
  docstring = "#5a8fa3",        -- cooler hue for docstrings
  red       = "#dc2626",        -- red-600 colorblind-safe
  red_b     = "#d86868",
  red_light = "#f5a5a5",        -- super light red for text highlights
  amber     = "#f59e0b",        -- amber-500 colorblind-safe
  green     = "#49d36d",
  green_b   = "#60e185",
  yellow    = "#d6a800",
  yellow_b  = "#e9bf1a",
  blue      = "#3b82f6",        -- blue-500 colorblind-safe
  purple    = "#6e3ac2",
  purple_b  = "#8350d8",
  cyan      = "#22d3ee",        -- cyan-400 for types
  cyan_dim  = "#67e8f9",        -- cyan-300 dimmer
  orange    = "#b43232",
  orange_b  = "#d24747",
  brown     = "#7a5f3a",
  brown_b   = "#9b7a4d",
  white_d   = "#e6e6e6",
  punct_dim = "#555555",        -- dimmed punctuation
  param     = "#a78bfa",        -- purple-400 for parameters
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
  hi("CursorLine",     { bg="#0d0d0d" })
  hi("CursorLineNr",   { fg=C.yellow_b, bold=true })
  hi("SignColumn",     { bg=C.bg })
  hi("StatusLine",     { fg=C.white_d, bg="#101010" })
  hi("StatusLineNC",   { fg=C.muted, bg="#0e0e0e" })
  hi("Pmenu",          { fg=C.white_d, bg="#101010" })
  hi("PmenuSel",       { fg=C.bg, bg=C.orange_b, bold=true })
  hi("PmenuThumb",     { bg=C.border })
  hi("Visual",         { bg="#1e2a2e" })            -- brighter teal-tinted selection
  hi("Search",         { fg=C.bg, bg=C.red_light, bold=true })  -- super light red
  hi("IncSearch",      { fg=C.bg, bg=C.orange_b, bold=true })
  hi("MatchParen",     { fg=C.cyan, bg="#1a1a1a", bold=true })  -- clear matching paren
  hi("Whitespace",     { fg=C.border })
  hi("NonText",        { fg=C.border })
  hi("Comment",        { fg=C.comment, italic=true })           -- brighter muted cyan
  hi("Todo",           { fg=C.bg, bg=C.purple_b, bold=true })
  hi("Title",          { fg=C.white_d, bold=true })

  -- Syntax
  hi("Constant",       { fg=C.orange_b })
  hi("String",         { fg=C.green })
  hi("Number",         { fg=C.yellow_b })
  hi("Boolean",        { fg=C.purple_b })           -- booleans distinct
  hi("Identifier",     { fg=C.white_d })
  hi("Function",       { fg=C.orange_b, bold=true }) -- function names pop
  hi("Statement",      { fg=C.purple })             -- control flow keywords
  hi("Conditional",    { fg=C.purple_b })
  hi("Repeat",         { fg=C.purple_b })
  hi("Operator",       { fg=C.muted })
  hi("Keyword",        { fg=C.purple })
  hi("Include",        { fg=C.purple })
  hi("PreProc",        { fg=C.orange })
  hi("Type",           { fg=C.cyan })               -- types distinct cyan
  hi("Special",        { fg=C.red_b })
  hi("Delimiter",      { fg=C.punct_dim })          -- dimmed punctuation
  hi("Error",          { fg=C.bg, bg=C.red })
  hi("WarningMsg",     { fg=C.amber })
  hi("MoreMsg",        { fg=C.green_b })
  hi("Question",       { fg=C.green_b })

  -- Diagnostics (colorblind-safe)
  hi("DiagnosticError",{ fg=C.red })                -- red-600
  hi("DiagnosticWarn", { fg=C.amber })              -- amber-500
  hi("DiagnosticInfo", { fg=C.blue })               -- blue-500
  hi("DiagnosticHint", { fg=C.cyan_dim })
  hi("DiagnosticUnderlineError", { underline=true, sp=C.red })    -- underline not just undercurl
  hi("DiagnosticUnderlineWarn",  { underline=true, sp=C.amber })
  hi("DiagnosticUnderlineInfo",  { underline=true, sp=C.blue })
  hi("DiagnosticUnderlineHint",  { underline=true, sp=C.cyan_dim })
  hi("LspReferenceText",  { bg="#121212" })
  hi("LspReferenceRead",  { bg="#121212" })
  hi("LspReferenceWrite", { bg="#121212" })

  -- Git
  hi("DiffAdd",        { fg=C.green_b, bg="#09140e" })
  hi("DiffChange",     { fg=C.yellow_b, bg="#131006" })
  hi("DiffDelete",     { fg=C.red_b, bg="#140909" })
  hi("DiffText",       { fg=C.orange_b, bg="#1a120a" })
  hi("GitSignsAdd",    { fg=C.green })
  hi("GitSignsChange", { fg=C.yellow })
  hi("GitSignsDelete", { fg=C.red })

  -- Telescope
  hi("TelescopeNormal",{ fg=C.white_d, bg="#0f0f0f" })
  hi("TelescopeBorder",{ fg=C.border,  bg="#0f0f0f" })
  hi("TelescopeSelection", { fg=C.bg, bg=C.orange_b, bold=true })
  hi("TelescopeMatching", { fg=C.red_light, bold=true })           -- super light red for matched text
  hi("TelescopePromptPrefix", { fg=C.orange_b })

  -- Blink.cmp completion menu
  hi("BlinkCmpMenu", { fg=C.white_d, bg="#101010" })
  hi("BlinkCmpMenuSelection", { fg=C.bg, bg=C.orange_b, bold=true })
  hi("BlinkCmpLabel", { fg=C.white_d })
  hi("BlinkCmpLabelMatch", { fg=C.red_light, bold=true })          -- super light red for matched text
  hi("BlinkCmpKind", { fg=C.orange_b })

  -- NvimTree / Neo-tree common groups
  hi("Directory",      { fg=C.yellow_b })
  hi("ErrorMsg",       { fg=C.red_b })

  -- WhichKey
  hi("WhichKey",       { fg=C.purple_b })
  hi("WhichKeyGroup",  { fg=C.orange_b })
  hi("WhichKeyDesc",   { fg=C.white_d })

  -- Floating UI borders consistent with your border algo (brightened)
  -- Base border color brightened ~35%
  hi("FloatTitle",     { fg=C.orange_b, bg=C.surface, bold=true })

  -- Indent guides
  hi("IblIndent",      { fg="#141414" })            -- subtle indent guides
  hi("IblScope",       { fg="#252525" })            -- brighter active scope guide

  -- Python-specific (Treesitter)
  hi("@string.documentation.python", { fg=C.docstring, italic=true })  -- docstrings
  hi("@function.builtin.python",     { fg=C.green_b })                 -- len, print, etc
  hi("@variable.builtin.python",     { fg=C.purple_b })                -- self, cls
  hi("@constant.builtin.python",     { fg=C.purple_b })                -- True, False, None
  hi("@keyword.function.python",     { fg=C.purple_b, bold=true })     -- def
  hi("@keyword.type.python",         { fg=C.purple_b, bold=true })     -- class
  hi("@function.python",             { fg=C.orange_b, bold=true })     -- function names
  hi("@type.python",                 { fg=C.cyan })                    -- type hints
  hi("@variable.parameter.python",   { fg=C.param })                   -- parameters distinct
  hi("@punctuation.special.python",  { fg=C.orange })                  -- decorators @
  hi("@decorator.python",            { fg=C.orange, bold=true })       -- decorator names
  hi("@string.escape.python",        { fg=C.cyan })                    -- f-string {} expressions

  -- TypeScript/JavaScript (Treesitter)
  hi("@type.typescript",             { fg=C.cyan })                    -- TS types distinct
  hi("@type.builtin.typescript",     { fg=C.cyan_dim })                -- built-in types
  hi("@variable.parameter",          { fg=C.param })                   -- parameters
  hi("@variable.member",             { fg=C.white_d })                 -- object properties
  hi("@keyword.type",                { fg=C.purple_b })                -- interface, type
  hi("@constructor",                 { fg=C.yellow, bold=true })       -- class constructors

  -- LSP semantic tokens
  hi("@lsp.type.parameter",          { fg=C.param })                   -- parameters
  hi("@lsp.type.variable",           { fg=C.white_d })                 -- local variables
  hi("@lsp.type.property",           { fg=C.white_d })
  hi("@lsp.type.type",               { fg=C.cyan })                    -- types
  hi("@lsp.type.class",              { fg=C.yellow, bold=true })
  hi("@lsp.type.interface",          { fg=C.cyan, bold=true })
  hi("@lsp.type.decorator",          { fg=C.orange, bold=true })
  hi("@lsp.type.function",           { fg=C.orange_b, bold=true })

  -- General Treesitter enhancements
  hi("@punctuation.bracket",         { fg=C.punct_dim })               -- dimmed brackets
  hi("@punctuation.delimiter",       { fg=C.punct_dim })               -- dimmed punctuation
end

return M
