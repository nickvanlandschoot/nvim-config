local M = {}

local id_counter = 0

local function generate_id()
  id_counter = id_counter + 1
  return "node_" .. id_counter .. "_" .. os.time()
end

local valid_types = { box = true, phase = true, start = true, ["end"] = true }
local valid_layouts = { vertical = true, horizontal = true }

--- Create a new node.
--- @param type string "box"|"phase"|"start"|"end"
--- @param content string|string[] node label or lines
--- @param opts? table { id?, children?, layout?, metadata? }
--- @return table node
function M.create_node(type, content, opts)
  assert(valid_types[type], "invalid node type: " .. tostring(type))
  opts = opts or {}
  -- phases default to horizontal layout, others default to vertical
  local default_layout = (type == "phase") and "horizontal" or "vertical"
  return {
    id = opts.id or generate_id(),
    type = type,
    content = content,
    children = opts.children or {},
    layout = opts.layout or default_layout,
    metadata = opts.metadata or {},
  }
end

--- Create a starter tree with a single start box.
--- @param name string diagram name (stored in metadata)
--- @return table root node
function M.create_default_tree(name)
  return M.create_node("phase", name, {
    layout = "vertical",
    children = {
      M.create_node("start", "Start"),
    },
  })
end

--- Recursive DFS lookup by node ID.
--- @param root table
--- @param id string
--- @return table|nil
function M.find_node(root, id)
  if root.id == id then
    return root
  end
  for _, child in ipairs(root.children) do
    local found = M.find_node(child, id)
    if found then
      return found
    end
  end
  return nil
end

--- Find the parent of a node by its ID.
--- @param root table
--- @param id string
--- @return table|nil parent, number|nil index
function M.find_parent(root, id)
  for i, child in ipairs(root.children) do
    if child.id == id then
      return root, i
    end
    local parent, idx = M.find_parent(child, id)
    if parent then
      return parent, idx
    end
  end
  return nil, nil
end

--- Build breadcrumb path from root to node.
--- @param root table
--- @param id string
--- @return table[] list of nodes from root to target
function M.get_path(root, id)
  if root.id == id then
    return { root }
  end
  for _, child in ipairs(root.children) do
    local path = M.get_path(child, id)
    if #path > 0 then
      table.insert(path, 1, root)
      return path
    end
  end
  return {}
end

--- Insert a child node into parent at the given position.
--- @param parent table
--- @param child table
--- @param position? number 1-based index; nil = append
function M.add_child(parent, child, position)
  if position then
    table.insert(parent.children, position, child)
  else
    table.insert(parent.children, child)
  end
end

--- Remove a node from its parent by ID. Returns the removed node.
--- @param root table
--- @param node_id string
--- @return table|nil removed node
function M.remove_child(root, node_id)
  local parent, idx = M.find_parent(root, node_id)
  if parent and idx then
    return table.remove(parent.children, idx)
  end
  return nil
end

--- Reorder a child within its parent.
--- @param parent table
--- @param from number 1-based source index
--- @param to number 1-based destination index
function M.move_child(parent, from, to)
  if from < 1 or from > #parent.children then
    return
  end
  to = math.max(1, math.min(to, #parent.children))
  if from == to then
    return
  end
  local child = table.remove(parent.children, from)
  table.insert(parent.children, to, child)
end

--- Toggle layout between vertical and horizontal.
--- @param node table
function M.toggle_layout(node)
  if node.layout == "vertical" then
    node.layout = "horizontal"
  else
    node.layout = "vertical"
  end
end

--- Return a short display label for a node.
--- @param node table
--- @return string
function M.display_label(node)
  local content = node.content
  if type(content) == "table" then
    content = table.concat(content, " ")
  end
  local label = content or ""
  if #label > 40 then
    label = label:sub(1, 37) .. "..."
  end
  return string.format("[%s] %s", node.type, label)
end

--- Validate a node type string.
--- @param t string
--- @return boolean
function M.is_valid_type(t)
  return valid_types[t] == true
end

--- Validate a layout string.
--- @param l string
--- @return boolean
function M.is_valid_layout(l)
  return valid_layouts[l] == true
end

return M
