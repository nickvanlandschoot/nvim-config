-- intrace-light: light mode variant of intrace

local C = {
  bg        = "#f8f9fa",
  surface   = "#ffffff",
  border    = "#adb5bd",         -- visible borders
  border_s  = "#dee2e6",         -- subtle borders for dividers/indent
  fg        = "#212529",
  muted     = "#6c757d",
  comment   = "#0077aa",
  docstring = "#006688",
  red       = "#c92a2a",
  red_b     = "#e03131",
  red_light = "#ffc9c9",
  amber     = "#d9770b",
  green     = "#2f9e44",
  green_b   = "#37b24d",
  yellow    = "#c49800",
  yellow_b  = "#fcc419",
  blue      = "#1971c2",
  purple    = "#7048e8",
  purple_b  = "#9775fa",
  cyan      = "#0c8599",
  cyan_dim  = "#3bc9db",
  orange    = "#c2410c",
  orange_b  = "#d84a1b",
  brown     = "#8b5a3c",
  brown_b   = "#a06e4a",
  white_d   = "#495057",
  punct_dim = "#adb5bd",
  param     = "#7950f2",
}

local function hi(group, opts) vim.api.nvim_set_hl(0, group, opts) end

local M = {}
function M.load()
  vim.o.termguicolors = true

  -- ── Core ──────────────────────────────────────────────────────────────
  hi("Normal",         { fg=C.fg, bg=C.bg })
  hi("NormalNC",       { fg=C.fg, bg=C.bg })
  hi("NormalFloat",    { fg=C.fg, bg=C.surface })
  hi("FloatBorder",    { fg=C.brown_b, bg=C.surface })
  hi("FloatTitle",     { fg=C.orange_b, bg=C.surface, bold=true })
  hi("WinSeparator",   { fg=C.border })
  hi("VertSplit",      { fg=C.border })
  hi("MsgSeparator",   { fg=C.border })
  hi("WinBar",         { fg=C.fg, bg="#e9ecef" })
  hi("WinBarNC",       { fg=C.muted, bg="#f1f3f5" })

  -- ── Editor chrome ─────────────────────────────────────────────────────
  hi("LineNr",         { fg=C.muted, bg=C.bg })
  hi("LineNrAbove",    { fg=C.border, bg=C.bg })
  hi("LineNrBelow",    { fg=C.border, bg=C.bg })
  hi("CursorLine",     { bg="#f1f3f5" })
  hi("CursorLineNr",   { fg=C.orange_b, bold=true })
  hi("ColorColumn",    { bg="#f1f3f5" })
  hi("SignColumn",     { bg=C.bg })
  hi("FoldColumn",     { fg=C.muted, bg=C.bg })
  hi("Folded",         { fg=C.muted, bg="#e9ecef" })
  hi("Conceal",        { fg=C.muted })
  hi("SpecialKey",     { fg=C.border })
  hi("Whitespace",     { fg=C.border_s })
  hi("NonText",        { fg=C.border_s })
  hi("EndOfBuffer",    { fg=C.bg, bg=C.bg })

  -- ── Statusline / tabline ───────────────────────────────────────────────
  hi("StatusLine",     { fg=C.fg, bg="#e9ecef" })
  hi("StatusLineNC",   { fg=C.muted, bg="#f1f3f5" })
  hi("TabLine",        { fg=C.muted, bg="#e9ecef" })
  hi("TabLineSel",     { fg=C.fg, bg=C.bg, bold=true })
  hi("TabLineFill",    { bg="#e9ecef" })

  -- ── Popups / menus ────────────────────────────────────────────────────
  hi("Pmenu",          { fg=C.fg, bg="#e9ecef" })
  hi("PmenuSel",       { fg=C.surface, bg=C.orange_b, bold=true })
  hi("PmenuSbar",      { bg="#dee2e6" })
  hi("PmenuThumb",     { bg=C.border })
  hi("PmenuExtra",     { fg=C.muted, bg="#e9ecef" })

  -- ── Selection / search ────────────────────────────────────────────────
  hi("Visual",         { bg="#d0ebff" })
  hi("VisualNOS",      { bg="#d0ebff" })
  hi("Search",         { fg=C.fg, bg="#ffd8a8", bold=true })
  hi("IncSearch",      { fg=C.surface, bg=C.orange_b, bold=true })
  hi("CurSearch",      { fg=C.surface, bg=C.orange_b, bold=true })
  hi("MatchParen",     { fg=C.cyan, bg="#e9ecef", bold=true })
  hi("QuickFixLine",   { bg="#fff3bf" })

  -- ── Messages ──────────────────────────────────────────────────────────
  hi("Comment",        { fg=C.comment, italic=true })
  hi("Todo",           { fg=C.surface, bg=C.purple_b, bold=true })
  hi("Title",          { fg=C.fg, bold=true })
  hi("WarningMsg",     { fg=C.amber })
  hi("ErrorMsg",       { fg=C.red_b })
  hi("MoreMsg",        { fg=C.green_b })
  hi("ModeMsg",        { fg=C.fg, bold=true })
  hi("Question",       { fg=C.green_b })

  -- ── Spell ─────────────────────────────────────────────────────────────
  hi("SpellBad",       { undercurl=true, sp=C.red })
  hi("SpellCap",       { undercurl=true, sp=C.blue })
  hi("SpellRare",      { undercurl=true, sp=C.purple })
  hi("SpellLocal",     { undercurl=true, sp=C.cyan })

  -- ── Syntax ────────────────────────────────────────────────────────────
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
  hi("Directory",      { fg=C.yellow })

  -- ── Diagnostics ───────────────────────────────────────────────────────
  hi("DiagnosticError",            { fg=C.red })
  hi("DiagnosticWarn",             { fg=C.amber })
  hi("DiagnosticInfo",             { fg=C.blue })
  hi("DiagnosticHint",             { fg=C.cyan })
  hi("DiagnosticUnderlineError",   { underline=true, sp=C.red })
  hi("DiagnosticUnderlineWarn",    { underline=true, sp=C.amber })
  hi("DiagnosticUnderlineInfo",    { underline=true, sp=C.blue })
  hi("DiagnosticUnderlineHint",    { underline=true, sp=C.cyan })
  hi("DiagnosticVirtualTextError", { fg=C.red, bg="#ffe3e3" })
  hi("DiagnosticVirtualTextWarn",  { fg=C.amber, bg="#fff3bf" })
  hi("DiagnosticVirtualTextInfo",  { fg=C.blue, bg="#dbe4ff" })
  hi("DiagnosticVirtualTextHint",  { fg=C.cyan, bg="#e3fafc" })
  hi("LspReferenceText",           { bg="#e9ecef" })
  hi("LspReferenceRead",           { bg="#e9ecef" })
  hi("LspReferenceWrite",          { bg="#e9ecef" })
  hi("LspInlayHint",               { fg=C.muted, bg="#f1f3f5" })

  -- ── Diff UI (split/inline diff views) ─────────────────────────────────
  hi("DiffAdd",        { fg=C.green, bg="#d3f9d8" })
  hi("DiffChange",     { fg=C.yellow, bg="#fff3bf" })
  hi("DiffDelete",     { fg=C.red, bg="#ffe3e3" })
  hi("DiffText",       { fg=C.orange_b, bg="#ffd8a8" })

  -- diff filetype syntax (viewing .diff / git diff output)
  hi("diffAdded",      { fg=C.green, bg="#d3f9d8" })
  hi("diffRemoved",    { fg=C.red, bg="#ffe3e3" })
  hi("diffChanged",    { fg=C.yellow, bg="#fff3bf" })
  hi("diffLine",       { fg=C.blue, bg="#dbe4ff" })
  hi("diffFile",       { fg=C.muted, bg="#f1f3f5" })
  hi("diffOldFile",    { fg=C.red, bg="#f1f3f5" })
  hi("diffNewFile",    { fg=C.green, bg="#f1f3f5" })
  hi("diffIndexLine",  { fg=C.muted, bg="#f1f3f5" })
  hi("diffSubname",    { fg=C.cyan })

  -- Treesitter diff
  hi("@diff.plus",     { fg=C.green, bg="#d3f9d8" })
  hi("@diff.minus",    { fg=C.red, bg="#ffe3e3" })
  hi("@diff.delta",    { fg=C.blue, bg="#dbe4ff" })

  -- ── Git signs ─────────────────────────────────────────────────────────
  hi("GitSignsAdd",               { fg=C.green })
  hi("GitSignsChange",            { fg=C.yellow })
  hi("GitSignsDelete",            { fg=C.red })
  hi("GitSignsCurrentLineBlame",  { fg=C.border, italic=true })

  -- ── UFO folds ─────────────────────────────────────────────────────────
  -- UfoFoldedFg/Bg control the virtual text count shown on collapsed folds
  hi("UfoFoldedFg",              { fg=C.muted })
  hi("UfoFoldedBg",              { bg="#e9ecef" })
  hi("UfoCursorFoldedLine",      { bg="#f1f3f5", bold=true })
  hi("UfoPreviewSbar",           { bg="#dee2e6" })
  hi("UfoPreviewThumb",          { bg=C.border })
  hi("UfoPreviewWinBar",         { fg=C.fg, bg="#e9ecef" })
  hi("UfoPreviewCursorLine",     { bg="#d0ebff" })

  -- ── Telescope ─────────────────────────────────────────────────────────
  hi("TelescopeNormal",          { fg=C.fg, bg=C.surface })
  hi("TelescopeBorder",          { fg=C.border, bg=C.surface })
  hi("TelescopeSelection",       { fg=C.surface, bg=C.orange_b, bold=true })
  hi("TelescopeMatching",        { fg=C.orange, bold=true })
  hi("TelescopePromptPrefix",    { fg=C.orange_b })

  -- ── Blink.cmp ─────────────────────────────────────────────────────────
  hi("BlinkCmpMenu",             { fg=C.fg, bg="#e9ecef" })
  hi("BlinkCmpMenuSelection",    { fg=C.surface, bg=C.orange_b, bold=true })
  hi("BlinkCmpLabel",            { fg=C.fg })
  hi("BlinkCmpLabelMatch",       { fg=C.orange, bold=true })
  hi("BlinkCmpKind",             { fg=C.orange_b })
  hi("BlinkCmpDoc",              { fg=C.fg, bg=C.surface })
  hi("BlinkCmpDocBorder",        { fg=C.border, bg=C.surface })
  hi("BlinkCmpScrollBarThumb",   { bg=C.border })
  hi("BlinkCmpScrollBarGutter",  { bg="#dee2e6" })

  -- ── Trouble ───────────────────────────────────────────────────────────
  hi("TroubleNormal",            { fg=C.fg, bg=C.bg })
  hi("TroubleNormalNC",          { fg=C.muted, bg=C.bg })
  hi("TroubleText",              { fg=C.fg })
  hi("TroubleCount",             { fg=C.orange_b, bold=true })
  hi("TroubleIconError",         { fg=C.red })
  hi("TroubleIconWarn",          { fg=C.amber })
  hi("TroubleIconHint",          { fg=C.cyan })
  hi("TroubleIconInfo",          { fg=C.blue })

  -- ── Snacks notifier ───────────────────────────────────────────────────
  hi("SnacksNotifierInfo",         { fg=C.fg, bg=C.surface })
  hi("SnacksNotifierWarn",         { fg=C.amber, bg=C.surface })
  hi("SnacksNotifierError",        { fg=C.red, bg=C.surface })
  hi("SnacksNotifierDebug",        { fg=C.muted, bg=C.surface })
  hi("SnacksNotifierTrace",        { fg=C.muted, bg=C.surface })
  hi("SnacksNotifierBorderInfo",   { fg=C.border, bg=C.surface })
  hi("SnacksNotifierBorderWarn",   { fg=C.amber, bg=C.surface })
  hi("SnacksNotifierBorderError",  { fg=C.red, bg=C.surface })
  hi("SnacksNotifierBorderDebug",  { fg=C.border, bg=C.surface })
  hi("SnacksNotifierBorderTrace",  { fg=C.border, bg=C.surface })
  hi("SnacksNotifierTitleInfo",    { fg=C.blue, bold=true })
  hi("SnacksNotifierTitleWarn",    { fg=C.amber, bold=true })
  hi("SnacksNotifierTitleError",   { fg=C.red, bold=true })
  hi("SnacksNotifierTitleDebug",   { fg=C.muted, bold=true })
  hi("SnacksNotifierTitleTrace",   { fg=C.muted, bold=true })

  -- ── render-markdown ───────────────────────────────────────────────────
  hi("RenderMarkdownH1",         { fg=C.purple, bold=true })
  hi("RenderMarkdownH2",         { fg=C.cyan, bold=true })
  hi("RenderMarkdownH3",         { fg=C.amber, bold=true })
  hi("RenderMarkdownH4",         { fg=C.blue, bold=true })
  hi("RenderMarkdownH5",         { fg=C.purple_b, bold=true })
  hi("RenderMarkdownH6",         { fg=C.purple })
  hi("RenderMarkdownCode",       { bg="#f1f3f5" })
  hi("RenderMarkdownCodeInline", { fg=C.red, bg="#f1f3f5" })
  hi("RenderMarkdownBullet",     { fg=C.orange_b })
  hi("RenderMarkdownLink",       { fg=C.blue, underline=true })
  hi("RenderMarkdownQuote",      { fg=C.muted, italic=true })

  -- ── Oil.nvim ──────────────────────────────────────────────────────────
  hi("OilDir",                   { fg=C.yellow, bold=true })
  hi("OilDirIcon",               { fg=C.yellow })
  hi("OilFile",                  { fg=C.fg })
  hi("OilSocket",                { fg=C.purple_b })
  hi("OilLink",                  { fg=C.cyan })
  hi("OilLinkTarget",            { fg=C.cyan, italic=true })
  hi("OilCopy",                  { fg=C.green, bold=true })
  hi("OilMove",                  { fg=C.amber, bold=true })
  hi("OilDelete",                { fg=C.red, bold=true })
  hi("OilCreate",                { fg=C.green, bold=true })
  hi("OilChange",                { fg=C.yellow })
  hi("OilPermissionNone",        { fg=C.border })
  hi("OilPermissionRead",        { fg=C.green })
  hi("OilPermissionWrite",       { fg=C.amber })
  hi("OilPermissionExecute",     { fg=C.red })

  -- ── Rainbow delimiters ────────────────────────────────────────────────
  hi("RainbowDelimiterRed",      { fg=C.red })
  hi("RainbowDelimiterYellow",   { fg=C.yellow })
  hi("RainbowDelimiterBlue",     { fg=C.blue })
  hi("RainbowDelimiterOrange",   { fg=C.orange_b })
  hi("RainbowDelimiterGreen",    { fg=C.green })
  hi("RainbowDelimiterViolet",   { fg=C.purple })
  hi("RainbowDelimiterCyan",     { fg=C.cyan })

  -- ── WhichKey ──────────────────────────────────────────────────────────
  hi("WhichKey",                 { fg=C.purple_b })
  hi("WhichKeyGroup",            { fg=C.orange_b })
  hi("WhichKeyDesc",             { fg=C.fg })
  hi("WhichKeyNormal",           { bg=C.surface })
  hi("WhichKeySeparator",        { fg=C.border })
  hi("WhichKeyValue",            { fg=C.muted })

  -- ── Indent guides ─────────────────────────────────────────────────────
  hi("IblIndent",                { fg="#e9ecef" })
  hi("IblScope",                 { fg="#dee2e6" })

  -- ── Python (Treesitter) ───────────────────────────────────────────────
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

  -- ── TypeScript/JavaScript (Treesitter) ────────────────────────────────
  hi("@type.typescript",             { fg=C.cyan })
  hi("@type.builtin.typescript",     { fg=C.cyan_dim })
  hi("@variable.parameter",          { fg=C.param })
  hi("@variable.member",             { fg=C.fg })
  hi("@keyword.type",                { fg=C.purple_b })
  hi("@constructor",                 { fg=C.yellow, bold=true })

  -- ── LSP semantic tokens ───────────────────────────────────────────────
  hi("@lsp.type.parameter",          { fg=C.param })
  hi("@lsp.type.variable",           { fg=C.fg })
  hi("@lsp.type.property",           { fg=C.fg })
  hi("@lsp.type.type",               { fg=C.cyan })
  hi("@lsp.type.class",              { fg=C.yellow, bold=true })
  hi("@lsp.type.interface",          { fg=C.cyan, bold=true })
  hi("@lsp.type.decorator",          { fg=C.brown_b, bold=true })
  hi("@lsp.type.function",           { fg=C.orange_b, bold=true })
  hi("@lsp.type.enumMember",         { fg=C.orange })
  hi("@lsp.type.enum",               { fg=C.yellow, bold=true })
  hi("@lsp.type.namespace",          { fg=C.fg })
  hi("@lsp.type.comment",            { fg=C.comment, italic=true })

  -- ── General Treesitter ────────────────────────────────────────────────
  hi("@punctuation.bracket",         { fg=C.punct_dim })
  hi("@punctuation.delimiter",       { fg=C.punct_dim })
  hi("@string.special.url",          { fg=C.blue, underline=true })
  hi("@markup.link.url",             { fg=C.blue, underline=true })
  hi("@markup.raw.block",            { bg="#f1f3f5" })
  hi("@markup.heading",              { fg=C.fg, bold=true })
end

return M
