-- intrace: the canonical high-contrast Intrace palette.
-- The signature Intrace red (#d24747) is preserved exactly as `accent`.

local C = {
  background    = "dark",

  bg            = "#0a0a0a",
  bg_alt        = "#0e0e11",
  surface       = "#141417",
  surface_alt   = "#202027",
  border        = "#414148",
  border_strong = "#64646e",
  selection     = "#526770",
  reference     = "#303038",
  reference_r   = "#263f47",
  reference_w   = "#4b3338",
  search        = "#f5a5a5",
  diff_add      = "#0d2115",
  diff_change   = "#241f10",
  diff_delete   = "#281416",
  search_fg     = "#0a0a0a",
  yellow_fg     = "#0a0a0a",
  todo_fg       = "#0a0a0a",
  error_fg      = "#0a0a0a",
  selection_fg  = "#f6eeee",

  fg            = "#f0f0f2",
  fg_soft       = "#dddddf",
  fg_bright     = "#f6eeee",
  muted         = "#888892",
  comment       = "#6b9fb5",
  docstring     = "#6995a5",
  punctuation   = "#888892",

  accent        = "#d24747",
  accent_fg     = "#000000",
  accent_text   = "#df7070",
  accent_soft   = "#e18484",
  accent_bright = "#eba0a0",

  red           = "#e15a65",
  amber         = "#cf9338",
  green         = "#49c66d",
  green_bright  = "#5bd47d",
  yellow        = "#c59a26",
  yellow_bright = "#d5ad3d",
  blue          = "#638bd0",
  purple        = "#9a78d0",
  purple_bright = "#aa8add",
  cyan          = "#35b8cd",
  cyan_dim      = "#719da7",
  hint          = "#668f9a",
  brown_bright  = "#a8875e",
  parameter     = "#ad91e6",

  terminal_black        = "#0a0a0a",
  terminal_white        = "#f0f0f2",
  terminal_bright_black = "#888892",
  terminal_bright_white = "#f6eeee",
}

local M = {}

function M.load()
  require("intrace.theme").apply(C)
end

return M
