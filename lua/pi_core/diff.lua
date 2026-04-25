local config = require("pi_core.config")
local util = require("pi_core.util")

local M = {
  queue = {},
  current = nil,
}

local excluded_dirs = {
  [".git"] = true,
  [".hg"] = true,
  [".svn"] = true,
  [".cache"] = true,
  [".next"] = true,
  [".nuxt"] = true,
  [".venv"] = true,
  ["__pycache__"] = true,
  ["coverage"] = true,
  ["dist"] = true,
  ["node_modules"] = true,
  ["target"] = true,
  ["vendor"] = true,
}

local function scan_project_files(root)
  local diff_cfg = config.get().diff or {}
  local max_files = diff_cfg.max_scan_files or 2000
  local max_file_bytes = diff_cfg.max_file_bytes or (1024 * 1024)
  local files = {}
  local count = 0

  local function walk(dir, prefix)
    if count >= max_files then
      return
    end

    local fs = vim.uv.fs_scandir(dir)
    if not fs then
      return
    end

    while count < max_files do
      local name, type = vim.uv.fs_scandir_next(fs)
      if not name then
        break
      end
      if name ~= ".DS_Store" then
        local full = dir .. "/" .. name
        local rel = prefix ~= "" and (prefix .. "/" .. name) or name
        if type == "directory" then
          if not excluded_dirs[name] then
            walk(full, rel)
          end
        elseif type == "file" then
          local stat = vim.uv.fs_stat(full)
          if stat and stat.size <= max_file_bytes then
            count = count + 1
            files[rel] = util.read_file(full)
          end
        end
      end
    end
  end

  walk(root, "")
  return files
end

local function relpath(root, path)
  if path:sub(1, #root + 1) == root .. "/" then
    return path:sub(#root + 2)
  end
  return path
end

local function abs(root, path)
  return root .. "/" .. path
end

local function capture_project_snapshot(root)
  root = root or util.cwd()
  return {
    root = root,
    project_snapshot = true,
    contents = scan_project_files(root),
  }
end

local function capture_snapshot()
  return capture_project_snapshot(util.cwd())
end

local function project_candidate_changes(snapshot)
  local after = scan_project_files(snapshot.root)
  local seen = {}
  local touched = {}

  for path in pairs(snapshot.contents or {}) do
    seen[path] = true
  end
  for path in pairs(after) do
    seen[path] = true
  end

  for path in pairs(seen) do
    local before_content = snapshot.contents and snapshot.contents[path] or nil
    local after_content = after[path]
    if before_content ~= after_content then
      table.insert(touched, {
        root = snapshot.root,
        path = path,
        abs_path = abs(snapshot.root, path),
        before = before_content,
        after = after_content,
      })
    end
  end

  table.sort(touched, function(a, b)
    return a.path < b.path
  end)
  return touched
end

local function candidate_changes(snapshot)
  return project_candidate_changes(snapshot)
end

local function restore_path(item)
  if item.before == nil then
    if util.path_exists(item.abs_path) then
      os.remove(item.abs_path)
    end
  else
    util.write_file(item.abs_path, item.before)
  end

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr) == item.abs_path then
      if util.path_exists(item.abs_path) then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("edit!")
        end)
      else
        pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
      end
    end
  end
end

local function detect_filetype(path)
  return util.filetype_for_path(path)
end

local function create_scratch(name, path, content)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].readonly = false
  vim.api.nvim_buf_set_name(bufnr, name)
  local lines = {}
  if content and content ~= "" then
    lines = vim.split(content, "\n", { plain = true })
    if lines[#lines] == "" then
      table.remove(lines, #lines)
    end
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].readonly = true
  local ft = detect_filetype(path)
  if ft and ft ~= "" then
    vim.bo[bufnr].filetype = ft
  end
  return bufnr
end

local function restore_cursor(winid, cursor)
  if not cursor then
    return
  end
  local group = vim.api.nvim_create_augroup("PiDiffCursorRestore", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = group,
    once = true,
    callback = function()
      pcall(vim.api.nvim_win_set_cursor, winid, cursor)
      pcall(vim.api.nvim_del_augroup_by_id, group)
    end,
  })
end

local function find_main_editor_window()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local windows = vim.api.nvim_tabpage_list_wins(current_tab)

  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
    local win_config = vim.api.nvim_win_get_config(win)
    local relative = win_config.relative
    local floating = relative and relative ~= ""

    local blocked_filetype = filetype == "neo-tree"
      or filetype == "neo-tree-popup"
      or filetype == "NvimTree"
      or filetype == "oil"
      or filetype == "minifiles"
      or filetype == "netrw"
      or filetype == "aerial"
      or filetype == "tagbar"
      or filetype == "snacks_picker_list"
      or filetype == "pi-terminal"

    if not floating and buftype ~= "terminal" and buftype ~= "prompt" and not blocked_filetype then
      return win
    end
  end

  return nil
end

local function buffer_visible(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
        return true
      end
    end
  end
  return false
end

local function close_current()
  local current = M.current
  if not current then
    return
  end
  local origin_win = current.origin_win
  local origin_buf = current.origin_buf
  local origin_cursor = current.origin_cursor
  local target_path = current.item and current.item.abs_path or nil
  local old_buf = current.old_buf
  local new_win = current.new_win
  local new_buf = current.new_buf
  M.current = nil

  local restore_win = nil
  if origin_win and vim.api.nvim_win_is_valid(origin_win) then
    restore_win = origin_win
  elseif new_win and vim.api.nvim_win_is_valid(new_win) then
    restore_win = new_win
  else
    restore_win = find_main_editor_window()
    if not restore_win then
      local current_win = vim.api.nvim_get_current_win()
      if current_win and vim.api.nvim_win_is_valid(current_win) then
        restore_win = current_win
      end
    end
  end

  if restore_win and vim.api.nvim_win_is_valid(restore_win) then
    pcall(vim.api.nvim_set_current_win, restore_win)
    if origin_buf and vim.api.nvim_buf_is_valid(origin_buf) then
      pcall(vim.api.nvim_win_set_buf, restore_win, origin_buf)
    elseif target_path and util.path_exists(target_path) then
      pcall(vim.cmd, "edit " .. vim.fn.fnameescape(target_path))
      origin_buf = vim.api.nvim_win_get_buf(restore_win)
    else
      local fallback_buf = vim.api.nvim_create_buf(true, false)
      pcall(vim.api.nvim_win_set_buf, restore_win, fallback_buf)
      origin_buf = fallback_buf
    end

    pcall(vim.cmd, "diffoff!")
    restore_cursor(restore_win, origin_cursor)
  end

  if new_win and vim.api.nvim_win_is_valid(new_win) and new_win ~= restore_win then
    pcall(vim.api.nvim_win_close, new_win, true)
  end

  if old_buf and vim.api.nvim_buf_is_valid(old_buf) and not buffer_visible(old_buf) then
    pcall(vim.api.nvim_buf_delete, old_buf, { force = true })
  end
  if new_buf and vim.api.nvim_buf_is_valid(new_buf) and not buffer_visible(new_buf) then
    pcall(vim.api.nvim_buf_delete, new_buf, { force = true })
  end
end

local function open_item(item)
  local origin_win = find_main_editor_window() or vim.api.nvim_get_current_win()
  local origin_buf = vim.api.nvim_win_get_buf(origin_win)
  local origin_cursor = vim.api.nvim_win_get_cursor(origin_win)
  local old_buf = create_scratch(item.path .. " (before)", item.abs_path, item.before)
  local new_buf = create_scratch(item.path .. " (after)", item.abs_path, item.after)

  vim.api.nvim_set_current_win(origin_win)
  vim.api.nvim_win_set_buf(origin_win, old_buf)
  vim.wo[origin_win].wrap = false
  vim.cmd("diffthis")

  if config.get().diff.layout == "horizontal" then
    vim.cmd("belowright split")
  else
    vim.cmd("rightbelow vsplit")
  end
  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_win, new_buf)
  vim.wo[new_win].wrap = false
  vim.cmd("diffthis")
  vim.cmd("wincmd =")

  M.current = {
    item = item,
    old_buf = old_buf,
    new_buf = new_buf,
    new_win = new_win,
    origin_win = origin_win,
    origin_buf = origin_buf,
    origin_cursor = origin_cursor,
  }

  util.notify(string.format("Reviewing %s (%d remaining)", item.path, #M.queue + 1))
end

function M.has_active_review()
  return M.current ~= nil
end

function M.capture_snapshot()
  return capture_snapshot()
end

function M.capture_project_snapshot(root)
  return capture_project_snapshot(root)
end

local function normalize_tool_path(root, path)
  if not path or path == "" then
    return nil, nil
  end
  local abs_path = path
  if not abs_path:match("^/") then
    abs_path = abs(root, path)
  end
  abs_path = vim.fn.fnamemodify(abs_path, ":p")
  local rel = relpath(root, abs_path:gsub("/$", ""))
  return abs_path:gsub("/$", ""), rel
end

local function replace_once(text, old, new)
  old = old or ""
  new = new or ""
  if old == "" then
    return text, false
  end
  local escaped = vim.pesc(old)
  local replaced, count = text:gsub(escaped, function()
    return new
  end, 1)
  return replaced, count > 0
end

local function insert_at_line(text, line_nr, insert_text)
  if not line_nr or line_nr < 1 or not insert_text or insert_text == "" then
    return text, false
  end
  local lines = vim.split(text or "", "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines, #lines)
  end
  local insert_lines = vim.split(insert_text, "\n", { plain = true })
  if insert_lines[#insert_lines] == "" then
    table.remove(insert_lines, #insert_lines)
  end
  local idx = math.min(math.max(line_nr, 1), #lines + 1)
  for i = #insert_lines, 1, -1 do
    table.insert(lines, idx, insert_lines[i])
  end
  local trailing = text and text:sub(-1) == "\n"
  local out = table.concat(lines, "\n")
  if trailing or insert_text:sub(-1) == "\n" then
    out = out .. "\n"
  end
  return out, true
end

local function reverse_edit_args(after, args, details)
  if not after or type(args) ~= "table" or type(args.edits) ~= "table" then
    return nil
  end
  local before = after
  for i = #args.edits, 1, -1 do
    local edit = args.edits[i]
    local old_text = edit.oldText or edit.old_text or ""
    local new_text = edit.newText or edit.new_text or ""
    local ok = false
    if new_text ~= "" then
      before, ok = replace_once(before, new_text, old_text)
    elseif old_text ~= "" and details and details.firstChangedLine then
      before, ok = insert_at_line(before, details.firstChangedLine, old_text)
    end
    if not ok then
      return nil
    end
  end
  return before
end

function M.enqueue_tool_review(event, snapshot)
  if not config.get().diff.enabled or type(event) ~= "table" or event.isError then
    return 0
  end

  local args = event.arguments or {}
  local root = (snapshot and snapshot.root) or util.cwd()
  local abs_path, path = normalize_tool_path(root, args.path or event.path)
  if not abs_path or not path then
    return 0
  end

  local after = util.read_file(abs_path)
  local before
  if snapshot and snapshot.contents then
    before = snapshot.contents[path]
  elseif event.before_captured then
    before = event.before
  end

  if before == nil and event.toolName == "edit" then
    before = reverse_edit_args(after, args, event.details)
  end

  if before == after then
    return 0
  end

  table.insert(M.queue, {
    root = root,
    path = path,
    abs_path = abs_path,
    before = before,
    after = after,
  })

  if config.get().diff.auto_open and not M.current then
    M.open_next()
  else
    util.notify(string.format("pi review queue: %d file(s)", #M.queue), vim.log.levels.INFO)
  end
  return 1
end

function M.enqueue_review(snapshot)
  if not config.get().diff.enabled or not snapshot then
    return 0
  end
  local touched = candidate_changes(snapshot)
  if #touched == 0 then
    return 0
  end
  for _, item in ipairs(touched) do
    table.insert(M.queue, item)
  end
  if config.get().diff.auto_open and not M.current then
    M.open_next()
  else
    util.notify(string.format("pi review queue: %d file(s)", #M.queue), vim.log.levels.INFO)
  end
  return #touched
end

function M.open_next()
  if M.current or #M.queue == 0 then
    return
  end
  open_item(table.remove(M.queue, 1))
end

function M.accept_current()
  if not M.current then
    util.notify("No active pi diff review", vim.log.levels.WARN)
    return
  end
  close_current()
  if #M.queue > 0 then
    M.open_next()
  else
    util.notify("pi review complete", vim.log.levels.INFO)
  end
end

function M.deny_current()
  if not M.current then
    util.notify("No active pi diff review", vim.log.levels.WARN)
    return
  end
  restore_path(M.current.item)
  close_current()
  if #M.queue > 0 then
    M.open_next()
  else
    util.notify("pi review complete", vim.log.levels.INFO)
  end
end

function M.cascade_deny_current()
  if not M.current then
    util.notify("No active pi diff review", vim.log.levels.WARN)
    return 0
  end

  local items = { M.current.item }
  for _, item in ipairs(M.queue) do
    table.insert(items, item)
  end
  M.queue = {}

  local restore_items = {}
  local seen = {}
  for _, item in ipairs(items) do
    if item and item.abs_path and not seen[item.abs_path] then
      seen[item.abs_path] = true
      table.insert(restore_items, item)
    end
  end

  for _, item in ipairs(restore_items) do
    restore_path(item)
  end
  close_current()

  util.notify(string.format("pi cascade rejected %d file(s)", #restore_items), vim.log.levels.INFO)
  return #restore_items
end

function M.clear()
  M.queue = {}
  close_current()
end

return M
