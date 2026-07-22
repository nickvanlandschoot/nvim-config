-- intrace-muted: low-chroma, readable variant of Intrace.
-- The signature Intrace red (#ab3838) is intentionally preserved as `accent`.

local C = {
  background    = "dark",

  -- Foundations
  bg            = "#1a1a1d",
  bg_alt        = "#1e1e22",
  surface       = "#242428",
  surface_alt   = "#2b2b30",
  border        = "#45454d",
  border_strong = "#6d6d76",
  selection     = "#596873",
  reference     = "#33333a",
  reference_r   = "#2f3d41",
  reference_w   = "#4a3436",
  search        = "#e0b8b8",
  diff_add      = "#17221a",
  diff_change   = "#242116",
  diff_delete   = "#28191b",
  search_fg     = "#1a1a1d",
  yellow_fg     = "#1a1a1d",
  todo_fg       = "#1a1a1d",
  error_fg      = "#1a1a1d",
  selection_fg  = "#f2e8e8",

  -- Text hierarchy
  fg            = "#c4c4c8",
  fg_soft       = "#b8b8bc",
  fg_bright     = "#f2e8e8",
  muted         = "#8d8d96",
  comment       = "#6d92a3",
  docstring     = "#6e929f",
  punctuation   = "#8d8d96",

  -- Intrace identity. Do not replace `accent` with a generic red.
  accent        = "#ab3838",
  accent_fg     = "#f2e8e8",
  accent_text   = "#c47777",
  accent_soft   = "#ca7f7f",
  accent_bright = "#d38b8b",

  -- Semantic colors are intentionally moderate in chroma while retaining
  -- enough lightness for normal-sized editor text on `bg` and `surface`.
  red           = "#d96c70",
  amber         = "#c98a06",
  green         = "#3aab5a",
  green_bright  = "#52bd6d",
  yellow        = "#b88800",
  yellow_bright = "#c99a18",
  blue          = "#748dc0",
  purple        = "#967fc7",
  purple_bright = "#a18bd0",
  cyan          = "#1dadc6",
  cyan_dim      = "#6a95a0",
  hint          = "#5f8994",
  brown_bright  = "#ad8b63",
  parameter     = "#a18bd0",

  -- Terminal anchors
  terminal_black        = "#1a1a1d",
  terminal_white        = "#c4c4c8",
  terminal_bright_black = "#8d8d96",
  terminal_bright_white = "#f2e8e8",
}

local M = {}

function M.load()
  require("intrace.theme").apply(C)
end

return M
