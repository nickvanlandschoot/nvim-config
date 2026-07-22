-- intrace-black: pure-black OLED variant of Intrace.
-- Pure black and the signature Intrace red (#d24747) are preserved exactly.

local C = {
  background    = "dark",

  bg            = "#000000",
  bg_alt        = "#050507",
  surface       = "#0c0c0f",
  surface_alt   = "#18181d",
  border        = "#414148",
  border_strong = "#64646e",
  selection     = "#526770",
  reference     = "#2c2c34",
  reference_r   = "#243c44",
  reference_w   = "#493137",
  search        = "#f5a5a5",
  diff_add      = "#071e10",
  diff_change   = "#211c0b",
  diff_delete   = "#241012",
  search_fg     = "#000000",
  yellow_fg     = "#000000",
  todo_fg       = "#000000",
  error_fg      = "#000000",
  selection_fg  = "#fff5f5",

  fg            = "#f5f5f7",
  fg_soft       = "#e2e2e5",
  fg_bright     = "#fff5f5",
  muted         = "#8c8c96",
  comment       = "#70a4ba",
  docstring     = "#6c98a8",
  punctuation   = "#8c8c96",

  accent        = "#d24747",
  accent_fg     = "#000000",
  accent_text   = "#df7474",
  accent_soft   = "#e28888",
  accent_bright = "#eda5a5",

  red           = "#e45e69",
  amber         = "#d3993e",
  green         = "#4dca72",
  green_bright  = "#60d883",
  yellow        = "#c9a02c",
  yellow_bright = "#d8b344",
  blue          = "#6790d5",
  purple        = "#9e7dd5",
  purple_bright = "#ae8ee2",
  cyan          = "#38bdd2",
  cyan_dim      = "#75a2ac",
  hint          = "#668f9a",
  brown_bright  = "#ac8b62",
  parameter     = "#b296ea",

  terminal_black        = "#000000",
  terminal_white        = "#f5f5f7",
  terminal_bright_black = "#8c8c96",
  terminal_bright_white = "#fff5f5",
}

local M = {}

function M.load()
  require("intrace.theme").apply(C)
end

return M
