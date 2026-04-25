local M = {}

-- Unicode box-drawing characters
local BOX = {
  tl = "┌", tr = "┐", bl = "└", br = "┘",
  h = "─", v = "│",
}

local PHASE = {
  tl = "╔", tr = "╗", bl = "╚", br = "╝",
  h = "═", v = "║",
}

local ARROW_DOWN = "▼"
local ARROW_SHAFT = "│"
local ARROW_RIGHT = "→"

--- Measure display width (handles multi-byte/Unicode).
local function strwidth(s)
  return vim.api.nvim_strwidth(s)
end

--- Create a string of `n` copies of character `ch`.
local function rep(ch, n)
  if n <= 0 then
    return ""
  end
  return string.rep(ch, n)
end

--- Pad a string on the right with spaces to reach `target_width`.
local function pad_right(s, target_width)
  local w = strwidth(s)
  if w >= target_width then
    return s
  end
  return s .. rep(" ", target_width - w)
end

--- Center a string within `target_width`.
local function center_str(s, target_width)
  local w = strwidth(s)
  if w >= target_width then
    return s
  end
  local left = math.floor((target_width - w) / 2)
  local right = target_width - w - left
  return rep(" ", left) .. s .. rep(" ", right)
end

--- @class Block
--- @field lines string[]
--- @field width number display width of widest line
--- @field connector_x number 0-based column for vertical connectors
--- @field connector_y number 0-based row for horizontal connectors (where → attaches)

--- Create a block structure.
local function make_block(lines, width, connector_x, connector_y)
  return {
    lines = lines,
    width = width,
    connector_x = connector_x,
    connector_y = connector_y or math.floor(#lines / 2),
  }
end

--- Normalize all lines in a block to the same display width.
local function normalize_block(block)
  local lines = {}
  for _, line in ipairs(block.lines) do
    lines[#lines + 1] = pad_right(line, block.width)
  end
  return make_block(lines, block.width, block.connector_x, block.connector_y)
end

--- Center a narrower block within a wider width.
--- Uses floor(target_width/2) as the new connector_x for consistency.
local function center_block(block, target_width)
  if block.width >= target_width then
    return block
  end
  local left_pad = math.floor((target_width - block.width) / 2)
  local lines = {}
  for _, line in ipairs(block.lines) do
    lines[#lines + 1] = pad_right(rep(" ", left_pad) .. pad_right(line, block.width), target_width)
  end
  return make_block(lines, target_width, block.connector_x + left_pad, block.connector_y)
end

--- Get the content lines of a node as a list of strings.
local function get_content_lines(node)
  local content = node.content
  if type(content) == "string" then
    return { content }
  elseif type(content) == "table" then
    return content
  end
  return { tostring(content or "") }
end

--- Render a single box (box, start, end types).
local function render_box(node)
  local content_lines = get_content_lines(node)

  local inner_width = 0
  for _, line in ipairs(content_lines) do
    inner_width = math.max(inner_width, strwidth(line))
  end
  inner_width = math.max(inner_width, 4)

  local total_width = inner_width + 4 -- "│ " + content + " │"
  local lines = {}

  lines[#lines + 1] = BOX.tl .. rep(BOX.h, total_width - 2) .. BOX.tr
  for _, cline in ipairs(content_lines) do
    lines[#lines + 1] = BOX.v .. " " .. center_str(cline, inner_width) .. " " .. BOX.v
  end
  lines[#lines + 1] = BOX.bl .. rep(BOX.h, total_width - 2) .. BOX.br

  -- connector_x at center, connector_y at first content line (row 1)
  local cx = math.floor(total_width / 2)
  local cy = 1
  return make_block(lines, total_width, cx, cy)
end

--- Render a vertical arrow connector.
local function render_arrow(width, connector_x)
  local shaft = pad_right(rep(" ", connector_x) .. ARROW_SHAFT, width)
  local head = pad_right(rep(" ", connector_x) .. ARROW_DOWN, width)
  return make_block({ shaft, head }, width, connector_x, 0)
end

--- Stack blocks vertically with arrow connectors between them.
--- Uses a single consistent connector_x = floor(max_width/2) to avoid off-by-one.
local function stack_vertical(blocks)
  if #blocks == 0 then
    return make_block({}, 0, 0, 0)
  end
  if #blocks == 1 then
    return blocks[1]
  end

  local max_width = 0
  for _, b in ipairs(blocks) do
    max_width = math.max(max_width, b.width)
  end

  -- Use a single consistent connector_x for the entire stack
  local connector_x = math.floor(max_width / 2)

  local result_lines = {}
  local first_cy = nil

  for i, b in ipairs(blocks) do
    local centered = center_block(normalize_block(b), max_width)
    if i > 1 then
      local arrow = render_arrow(max_width, connector_x)
      for _, line in ipairs(arrow.lines) do
        result_lines[#result_lines + 1] = line
      end
    end
    if i == 1 then
      first_cy = #result_lines + b.connector_y
    end
    for _, line in ipairs(centered.lines) do
      result_lines[#result_lines + 1] = line
    end
  end

  -- connector_y is the first block's content center
  return make_block(result_lines, max_width, connector_x, first_cy)
end

--- Place children sequentially left-to-right with → arrows between them.
--- Aligns blocks by their connector_y so arrows connect at content level.
local function join_sequential(child_blocks)
  if #child_blocks == 0 then
    return make_block({}, 0, 0, 0)
  end
  if #child_blocks == 1 then
    return child_blocks[1]
  end

  local arrow_str = " " .. ARROW_RIGHT .. " "
  local arrow_width = strwidth(arrow_str)

  -- normalize each child block
  local normalized = {}
  for i, cb in ipairs(child_blocks) do
    normalized[i] = normalize_block(cb)
  end

  -- Find the max connector_y so we can align all blocks at that row
  local max_cy = 0
  for _, cb in ipairs(normalized) do
    max_cy = math.max(max_cy, cb.connector_y)
  end

  -- Compute top padding for each block to align connector_y values
  local top_pads = {}
  local max_total_height = 0
  for i, cb in ipairs(normalized) do
    top_pads[i] = max_cy - cb.connector_y
    local total_h = top_pads[i] + #cb.lines
    max_total_height = math.max(max_total_height, total_h)
  end

  -- Compute total width
  local total_width = 0
  for i, cb in ipairs(normalized) do
    total_width = total_width + cb.width
    if i < #normalized then
      total_width = total_width + arrow_width
    end
  end

  -- The row where all arrows are drawn (0-based)
  local arrow_row = max_cy

  -- Compose rows
  local result_lines = {}
  for row = 0, max_total_height - 1 do
    local parts = {}
    for i, cb in ipairs(normalized) do
      -- arrow between blocks
      if i > 1 then
        if row == arrow_row then
          parts[#parts + 1] = arrow_str
        else
          parts[#parts + 1] = rep(" ", arrow_width)
        end
      end

      -- block content (offset by top_pad)
      local line_idx = row - top_pads[i] + 1 -- 1-based index into cb.lines
      if line_idx >= 1 and line_idx <= #cb.lines then
        parts[#parts + 1] = cb.lines[line_idx]
      else
        parts[#parts + 1] = rep(" ", cb.width)
      end
    end
    result_lines[#result_lines + 1] = pad_right(table.concat(parts), total_width)
  end

  -- connector_x: center of first block's absolute position
  local first_cx = normalized[1].connector_x
  return make_block(result_lines, total_width, first_cx, arrow_row)
end

--- Render a phase banner (double-line box wrapping children).
local function render_phase(node, inner_block)
  local content_lines = get_content_lines(node)
  local title = content_lines[1] or ""

  local inner_width = math.max(inner_block.width, strwidth(title))
  local total_width = inner_width + 4 -- "║ " + content + " ║"

  local centered_inner = center_block(normalize_block(inner_block), inner_width)

  local lines = {}

  -- top border (row 0)
  lines[#lines + 1] = PHASE.tl .. rep(PHASE.h, total_width - 2) .. PHASE.tr

  -- title (row 1)
  lines[#lines + 1] = PHASE.v .. " " .. center_str(title, inner_width) .. " " .. PHASE.v

  -- separator (row 2)
  lines[#lines + 1] = PHASE.v .. rep(PHASE.h, total_width - 2) .. PHASE.v

  -- blank (row 3)
  lines[#lines + 1] = PHASE.v .. rep(" ", total_width - 2) .. PHASE.v

  -- inner content starts at row 4
  for _, line in ipairs(centered_inner.lines) do
    lines[#lines + 1] = PHASE.v .. " " .. pad_right(line, inner_width) .. " " .. PHASE.v
  end

  -- blank
  lines[#lines + 1] = PHASE.v .. rep(" ", total_width - 2) .. PHASE.v

  -- bottom border
  lines[#lines + 1] = PHASE.bl .. rep(PHASE.h, total_width - 2) .. PHASE.br

  local cx = math.floor(total_width / 2)
  -- connector_y: title row for horizontal connections
  local cy = 1
  return make_block(lines, total_width, cx, cy)
end

--- Main recursive render function.
function M.render(node)
  if node.type == "box" or node.type == "start" or node.type == "end" then
    local box = render_box(node)

    if #node.children == 0 then
      return box
    end

    local child_blocks = {}
    for _, child in ipairs(node.children) do
      child_blocks[#child_blocks + 1] = M.render(child)
    end

    local children_block
    if node.layout == "horizontal" then
      children_block = join_sequential(child_blocks)
    else
      children_block = stack_vertical(child_blocks)
    end

    return stack_vertical({ box, children_block })
  end

  if node.type == "phase" then
    local child_blocks = {}
    for _, child in ipairs(node.children) do
      child_blocks[#child_blocks + 1] = M.render(child)
    end

    local inner_block
    if #child_blocks == 0 then
      inner_block = make_block({ "(empty)" }, 7, 3, 0)
    elseif node.layout == "horizontal" then
      inner_block = join_sequential(child_blocks)
    else
      inner_block = stack_vertical(child_blocks)
    end

    return render_phase(node, inner_block)
  end

  return render_box(node)
end

--- Render a tree to a list of strings.
function M.render_to_lines(tree)
  local block = M.render(tree)
  return block.lines
end

return M
