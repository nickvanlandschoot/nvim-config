-- intrace-light: complete light-mode expression of the Intrace palette.
-- The signature light Intrace orange-red (#d84a1b) is preserved as `accent`.

local C = {
  background    = "light",

  bg            = "#f8f9fa",
  bg_alt        = "#f1f3f5",
  surface       = "#ffffff",
  surface_alt   = "#e9ecef",
  border        = "#adb5bd",
  border_strong = "#68727c",
  selection     = "#456b84",
  reference     = "#d7e3ec",
  reference_r   = "#c9e3e8",
  reference_w   = "#f1d5d8",
  search        = "#f2b84b",
  diff_add      = "#eff8f1",
  diff_change   = "#fff8df",
  diff_delete   = "#fcebed",
  search_fg     = "#212529",
  yellow_fg     = "#ffffff",
  todo_fg       = "#ffffff",
  error_fg      = "#ffffff",
  selection_fg  = "#ffffff",

  fg            = "#212529",
  fg_soft       = "#343a40",
  fg_bright     = "#111418",
  muted         = "#687078",
  comment       = "#0077aa",
  docstring     = "#06698e",
  punctuation   = "#687078",

  accent        = "#d84a1b",
  accent_fg     = "#000000",
  accent_text   = "#b43b16",
  accent_soft   = "#a53b1a",
  accent_bright = "#8f3218",

  red           = "#c92a2a",
  amber         = "#9b5d00",
  green         = "#2f7f40",
  green_bright  = "#246b32",
  yellow        = "#806400",
  yellow_bright = "#806400",
  blue          = "#1971c2",
  purple        = "#7048e8",
  purple_bright = "#5f3dc4",
  cyan          = "#0b7285",
  cyan_dim      = "#356b75",
  hint          = "#4a6870",
  brown_bright  = "#8b5a3c",
  parameter     = "#6741d9",

  terminal_black        = "#212529",
  terminal_white        = "#ced4da",
  terminal_bright_black = "#6c757d",
  terminal_bright_white = "#ffffff",
}

local M = {}

function M.load()
  require("intrace.theme").apply(C)
end

return M
