-- Persistence for Claude diff plugin
--
-- RESPONSIBILITIES:
-- - Save hunk state to disk (JSON files)
-- - Load hunk state on buffer open
-- - Validate state (file modification time checks)
-- - Clean up stale state files
-- - No rendering, no buffer modification
local M = {}

-- Get the persistence directory
local function get_state_dir()
  local state_path = vim.fn.stdpath("state") .. "/claude_diff"
  vim.fn.mkdir(state_path, "p")
  return state_path
end

-- Convert file path to safe filename for state storage
local function path_to_filename(filepath)
  -- Replace path separators and special chars with underscores
  local safe = filepath:gsub("[/\\:]", "_"):gsub("[^%w_%-.]", "_")
  return safe .. ".json"
end

-- Get state file path for a given file
local function get_state_file(filepath)
  return get_state_dir() .. "/" .. path_to_filename(filepath)
end

-- Export get_state_file for testing
M.get_state_file = get_state_file

-- Get file modification time
local function get_file_mtime(filepath)
  local stat = vim.loop.fs_stat(filepath)
  return stat and stat.mtime.sec or nil
end

-- Save state for a buffer
function M.save_state(filepath, state)
  -- Don't save if there are no hunks
  if not state or not state.hunks or #state.hunks == 0 then
    -- Clean up old state file if it exists
    local state_file = get_state_file(filepath)
    pcall(vim.fn.delete, state_file)
    return
  end

  local state_file = get_state_file(filepath)

  -- Prepare state for serialization
  local data = {
    version = 1,
    filepath = filepath,
    mtime = get_file_mtime(filepath),
    baseline = state.baseline,
    hunks = state.hunks,
    user_ranges = state.user_ranges,
    saved_at = os.time(),
  }

  -- Serialize to JSON
  local ok, json = pcall(vim.json.encode, data)
  if not ok then
    vim.notify("Failed to serialize Claude diff state: " .. tostring(json), vim.log.levels.WARN)
    return
  end

  -- Write to file
  local file = io.open(state_file, "w")
  if file then
    file:write(json)
    file:close()
  else
    vim.notify("Failed to write Claude diff state file", vim.log.levels.WARN)
  end
end

-- Load state for a buffer
function M.load_state(filepath)
  local state_file = get_state_file(filepath)

  -- Check if state file exists
  if vim.fn.filereadable(state_file) == 0 then
    return nil
  end

  -- Read file
  local file = io.open(state_file, "r")
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()

  -- Parse JSON
  local ok, data = pcall(vim.json.decode, content)
  if not ok or not data then
    vim.notify("Failed to parse Claude diff state file", vim.log.levels.WARN)
    return nil
  end

  -- Validate version
  if data.version ~= 1 then
    vim.notify("Incompatible Claude diff state version", vim.log.levels.WARN)
    return nil
  end

  -- Validate file hasn't changed since state was saved
  local current_mtime = get_file_mtime(filepath)
  if current_mtime and data.mtime and current_mtime ~= data.mtime then
    -- File was modified, state is stale
    vim.notify("Claude diff state is stale (file was modified)", vim.log.levels.INFO)
    pcall(vim.fn.delete, state_file)
    return nil
  end

  -- Return the loaded state
  return {
    baseline = data.baseline or { lines = {}, tick = 0 },
    hunks = data.hunks or {},
    user_ranges = data.user_ranges or {},
  }
end

-- Clean up old state files (older than 30 days)
function M.cleanup_old_states()
  local state_dir = get_state_dir()
  local files = vim.fn.glob(state_dir .. "/*.json", false, true)
  local now = os.time()
  local max_age = 30 * 24 * 60 * 60 -- 30 days in seconds

  for _, file in ipairs(files) do
    local stat = vim.loop.fs_stat(file)
    if stat and stat.mtime.sec then
      local age = now - stat.mtime.sec
      if age > max_age then
        pcall(vim.fn.delete, file)
      end
    end
  end
end

return M
