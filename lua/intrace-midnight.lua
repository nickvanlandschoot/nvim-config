-- intrace-midnight: vivid syntax on a cohesive midnight-blue foundation.
-- The signature Midnight Intrace coral (#d8685c) is preserved as `accent`.

local C = {
  background    = "dark",

  -- Foundations stay tightly grouped around a blue-violet hue.
  bg            = "#10141d",
  bg_alt        = "#131720",
  surface       = "#1a202d",
  surface_alt   = "#232b3b",
  border        = "#3c465a",
  border_strong = "#637088",
  selection     = "#536f89",
  reference     = "#34465f",
  reference_r   = "#2b4b59",
  reference_w   = "#5d3d47",
  search        = "#f0b3ba",
  diff_add      = "#12251f",
  diff_change   = "#282315",
  diff_delete   = "#2b1920",
  search_fg     = "#10141d",
  yellow_fg     = "#10141d",
  todo_fg       = "#10141d",
  error_fg      = "#10141d",
  selection_fg  = "#f1f2f4",

  -- Text hierarchy
  fg            = "#dce0e6",
  fg_soft       = "#d0d3d8",
  fg_bright     = "#f1f2f4",
  muted         = "#878fa3",
  comment       = "#5b8fb0",
  docstring     = "#638eaa",
  punctuation   = "#7f879b",

  -- Intrace identity. The exact accent remains suitable for normal text and
  -- selection backgrounds in this variant, so no replacement is needed.
  accent        = "#d8685c",
  accent_fg     = "#10141d",
  accent_text   = "#d8685c",
  accent_soft   = "#e77d88",
  accent_bright = "#efa0aa",

  -- Semantic colors retain Midnight's vivid character while maintaining a
  -- balanced luminance hierarchy on both the editor and floating surfaces.
  red           = "#ed5b69",
  amber         = "#cf9850",
  green         = "#45b873",
  green_bright  = "#5bd08a",
  yellow        = "#d0a84d",
  yellow_bright = "#d6ae55",
  blue          = "#5b94d2",
  purple        = "#9280c8",
  purple_bright = "#a184df",
  cyan          = "#4eb4c9",
  cyan_dim      = "#70a0ae",
  hint          = "#668f9e",
  brown_bright  = "#a58d66",
  parameter     = "#a991f2",

  -- Terminal anchors
  terminal_black        = "#10141d",
  terminal_white        = "#dce0e6",
  terminal_bright_black = "#878fa3",
  terminal_bright_white = "#f1f2f4",
}

local M = {}

function M.load()
  require("intrace.theme").apply(C)
end

return M
