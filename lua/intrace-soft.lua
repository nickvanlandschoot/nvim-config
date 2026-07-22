-- intrace-soft: reduced-chroma Intrace for comfortable extended sessions.
-- The signature soft Intrace red (#bb4040) is preserved as `accent`.

local C = {
  background    = "dark",

  bg            = "#121215",
  bg_alt        = "#161619",
  surface       = "#1c1c21",
  surface_alt   = "#26262d",
  border        = "#414148",
  border_strong = "#686872",
  selection     = "#586d76",
  reference     = "#34343c",
  reference_r   = "#38434b",
  reference_w   = "#4b3338",
  search        = "#e8b4b4",
  diff_add      = "#14251a",
  diff_change   = "#282316",
  diff_delete   = "#2b1a1c",
  search_fg     = "#121215",
  yellow_fg     = "#121215",
  todo_fg       = "#121215",
  error_fg      = "#121215",
  selection_fg  = "#fff8f8",

  fg            = "#d4d4d8",
  fg_soft       = "#c8c8cc",
  fg_bright     = "#f0e8e8",
  muted         = "#898992",
  comment       = "#6090a3",
  docstring     = "#638c9a",
  punctuation   = "#898992",

  accent        = "#bb4040",
  accent_fg     = "#fff8f8",
  accent_text   = "#cc7070",
  accent_soft   = "#d08080",
  accent_bright = "#db9999",

  red           = "#d26369",
  amber         = "#c98f36",
  green         = "#3fbb5e",
  green_bright  = "#52c86d",
  yellow        = "#ba9020",
  yellow_bright = "#c9a13a",
  blue          = "#6285c7",
  purple        = "#947ac5",
  purple_bright = "#a589d2",
  cyan          = "#2aafc5",
  cyan_dim      = "#6d9da7",
  hint          = "#638d98",
  brown_bright  = "#a58460",
  parameter     = "#9f88dd",

  terminal_black        = "#121215",
  terminal_white        = "#d4d4d8",
  terminal_bright_black = "#898992",
  terminal_bright_white = "#fff8f8",
}

local M = {}

function M.load()
  require("intrace.theme").apply(C)
end

return M
