local M = {}

local METADATA_PREFIX = "%%"

--- Fields to persist. Everything else is transient.
local persist_fields = {
  id = true,
  type = true,
  content = true,
  children = true,
  layout = true,
  metadata = true,
}

--- Recursively strip transient fields from a node tree before serialization.
--- Returns a new table (does not mutate the original).
--- @param node table
--- @return table
local function strip(node)
  local clean = {}
  for k, v in pairs(node) do
    if persist_fields[k] then
      if k == "children" then
        clean.children = {}
        for i, child in ipairs(v) do
          clean.children[i] = strip(child)
        end
      else
        clean[k] = v
      end
    end
  end
  return clean
end

--- Encode a tree into a single metadata line (prefixed with %%).
--- @param tree table root node
--- @return string
function M.encode(tree)
  local clean = strip(tree)
  return METADATA_PREFIX .. vim.json.encode(clean)
end

--- Decode a metadata line back into a node tree.
--- @param line string a line starting with %%
--- @return table|nil root node, or nil on failure
function M.decode(line)
  -- Strip the literal "%%" prefix (2 characters)
  if not vim.startswith(line, METADATA_PREFIX) then
    return nil
  end
  local json_str = line:sub(#METADATA_PREFIX + 1)
  if json_str == "" then
    return nil
  end
  local ok, result = pcall(vim.json.decode, json_str)
  if ok then
    return result
  end
  return nil
end

--- Check whether a line is a metadata line.
--- @param line string
--- @return boolean
function M.is_metadata_line(line)
  return vim.startswith(line, METADATA_PREFIX)
end

return M
