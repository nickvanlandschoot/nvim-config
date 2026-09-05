local config = require("pi_core.config")
local util = require("pi_core.util")

local M = {
  queue = {},
  current = nil,
  badge = nil,
  files_expanded = false,
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

local inline_ns = vim.api.nvim_create_namespace("pi_inline_diff")
local buffer_content
local set_buffer_content

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

local function ensure_inline_highlights()
  pcall(vim.api.nvim_set_hl, 0, "PiDiffAdd", { link = "DiffAdd", default = true })
  pcall(vim.api.nvim_set_hl, 0, "PiDiffDelete", { link = "DiffDelete", default = true })
  pcall(vim.api.nvim_set_hl, 0, "PiDiffChange", { link = "DiffChange", default = true })
  pcall(vim.api.nvim_set_hl, 0, "PiDiffCurrent", { link = "DiffText", default = true })
  pcall(vim.api.nvim_set_hl, 0, "PiDiffBadge", { link = "NormalFloat", default = true })
  pcall(vim.api.nvim_set_hl, 0, "PiDiffBadgeBorder", { link = "FloatBorder", default = true })
end

local function split_content(content)
  if not content or content == "" then
    return {}
  end
  local lines = vim.split(content, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines, #lines)
  end
  return lines
end

local function content_has_final_newline(content)
  return type(content) == "string" and content ~= "" and content:sub(-1) == "\n"
end

local function join_lines(lines, final_newline)
  if #lines == 0 then
    return ""
  end
  local content = table.concat(lines, "\n")
  if final_newline then
    content = content .. "\n"
  end
  return content
end

local function clamp(value, min_value, max_value)
  if value < min_value then
    return min_value
  end
  if value > max_value then
    return max_value
  end
  return value
end

local function slice_lines(lines, start_idx, count)
  local out = {}
  if count <= 0 then
    return out
  end
  for i = start_idx, start_idx + count - 1 do
    table.insert(out, lines[i] or "")
  end
  return out
end

local function splice_index(start_idx, count)
  if count == 0 then
    return start_idx + 1
  end
  return start_idx
end

local function hunk_touches_eof(start_idx, count, line_count)
  if line_count == 0 then
    return true
  end
  if count == 0 then
    return start_idx >= line_count
  end
  return (start_idx + count - 1) >= line_count
end

local function replace_content_range(content, start_idx, count, replacement, final_newline)
  local lines = split_content(content)
  local idx = clamp(splice_index(start_idx, count), 1, #lines + 1)
  local removable = math.min(count, math.max(#lines - idx + 1, 0))

  for _ = 1, removable do
    table.remove(lines, idx)
  end
  for i = #replacement, 1, -1 do
    table.insert(lines, idx, replacement[i])
  end

  return join_lines(lines, final_newline)
end

local function review_kind(item)
  if item.before == nil and item.after ~= nil then
    return "new"
  end
  if item.before ~= nil and item.after == nil then
    return "deleted"
  end
  return "modified"
end

buffer_content = function(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 or (#lines == 1 and lines[1] == "") then
    return ""
  end
  local content = table.concat(lines, "\n")
  if vim.bo[bufnr].endofline then
    content = content .. "\n"
  end
  return content
end

set_buffer_content = function(bufnr, content, opts)
  opts = opts or {}
  content = content or ""

  local lines = split_content(content)
  local old_modifiable = vim.bo[bufnr].modifiable
  local old_readonly = vim.bo[bufnr].readonly

  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].readonly = false
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  pcall(function()
    vim.bo[bufnr].endofline = content == "" or content:sub(-1) == "\n"
  end)

  if opts.modified ~= nil then
    vim.bo[bufnr].modified = opts.modified
  end
  if opts.readonly ~= nil then
    vim.bo[bufnr].readonly = opts.readonly
  else
    vim.bo[bufnr].readonly = old_readonly
  end
  if opts.modifiable ~= nil then
    vim.bo[bufnr].modifiable = opts.modifiable
  else
    vim.bo[bufnr].modifiable = old_modifiable
  end
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

local function cleanup_empty_created_dirs(path, root)
  if not path or not root then
    return
  end
  local root_path = vim.fn.fnamemodify(root, ":p"):gsub("/$", "")
  local dir = vim.fn.fnamemodify(path, ":p:h"):gsub("/$", "")
  while dir ~= "" and dir ~= "/" and dir ~= root_path and dir:sub(1, #root_path + 1) == root_path .. "/" do
    local ok = vim.uv.fs_rmdir(dir)
    if not ok then
      break
    end
    dir = vim.fn.fnamemodify(dir, ":h"):gsub("/$", "")
  end
end

local function canonical_path(path)
  if not path or path == "" then
    return nil
  end
  local normalized = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
  local real = vim.uv.fs_realpath(normalized)
  return (real or normalized):gsub("/$", "")
end

local function loaded_file_buffer(path)
  local target = canonical_path(path)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name ~= "" and (name == path or canonical_path(name) == target) then
        return bufnr
      end
    end
  end
  return nil
end

local function refresh_loaded_buffer_if_safe(bufnr, item, disk_content)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local loaded_content = buffer_content(bufnr)
  if loaded_content == item.after then
    if disk_content == item.after and vim.bo[bufnr].modified then
      vim.bo[bufnr].modified = false
    end
    return
  end

  if vim.bo[bufnr].modified then
    local baseline = item.before or ""
    if disk_content == item.after and loaded_content == baseline then
      if item.after == nil then
        vim.bo[bufnr].modified = false
      else
        vim.api.nvim_buf_call(bufnr, function()
          set_buffer_content(bufnr, item.after, { modified = false })
        end)
      end
    end
    return
  end

  if disk_content == item.after and item.after ~= nil then
    vim.api.nvim_buf_call(bufnr, function()
      set_buffer_content(bufnr, item.after, { modified = false })
    end)
  end
end

local function can_apply_item(item)
  local bufnr = loaded_file_buffer(item.abs_path)
  local disk_content = util.read_file(item.abs_path)
  refresh_loaded_buffer_if_safe(bufnr, item, disk_content)

  local buffer_matches = true
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].modified then
    buffer_matches = buffer_content(bufnr) == item.after
  end

  if disk_content ~= item.after or not buffer_matches then
    util.notify(
      "pi review found unsaved or external changes; refusing to apply hunk for " .. item.path,
      vim.log.levels.WARN
    )
    return false
  end
  return true
end

local function write_review_content(item, content)
  local bufnr = loaded_file_buffer(item.abs_path)

  if content == nil then
    if util.path_exists(item.abs_path) then
      local ok, err = os.remove(item.abs_path)
      if not ok then
        util.notify("pi review could not delete " .. item.path .. ": " .. tostring(err), vim.log.levels.WARN)
        return false
      end
    end
    cleanup_empty_created_dirs(item.abs_path, item.root)
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) and not buffer_visible(bufnr) then
      pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
    end
    return true
  end

  if not util.write_file(item.abs_path, content) then
    util.notify("pi review could not write " .. item.path, vim.log.levels.WARN)
    return false
  end

  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_call(bufnr, function()
      set_buffer_content(bufnr, content, { modified = false })
    end)
  end
  return true
end

local function restore_path(item)
  return write_review_content(item, item.before)
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

local function set_file_buffer_in_window(winid, path)
  local bufnr = loaded_file_buffer(path) or vim.fn.bufadd(path)
  pcall(vim.fn.bufload, bufnr)
  vim.api.nvim_win_set_buf(winid, bufnr)
  return bufnr
end

local function open_file_in_window(winid, item)
  vim.api.nvim_set_current_win(winid)
  if item.after ~= nil and util.path_exists(item.abs_path) then
    local bufnr = set_file_buffer_in_window(winid, item.abs_path)
    if not vim.bo[bufnr].modified and buffer_content(bufnr) ~= item.after then
      set_buffer_content(bufnr, item.after, { modified = false })
    end
    return bufnr
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].swapfile = false
  vim.api.nvim_buf_set_name(bufnr, item.path .. " (pi deleted file review)")
  set_buffer_content(bufnr, item.before or "", { modified = false, readonly = true, modifiable = false })
  local ft = util.filetype_for_path(item.path)
  if ft and ft ~= "" then
    vim.bo[bufnr].filetype = ft
  end
  vim.api.nvim_win_set_buf(winid, bufnr)
  return bufnr
end

local function hunk_type(before_count, after_count)
  if before_count == 0 then
    return "add"
  end
  if after_count == 0 then
    return "delete"
  end
  return "change"
end

local function build_hunks(item)
  local hunks = {}
  if item.before == item.after then
    return hunks
  end

  local before_lines = split_content(item.before)
  local after_lines = split_content(item.after)
  local kind = review_kind(item)

  if kind == "new" then
    return {
      {
        kind = "new_file",
        before_start = 0,
        before_count = 0,
        after_start = #after_lines > 0 and 1 or 0,
        after_count = #after_lines,
        before_lines = {},
        after_lines = after_lines,
      },
    }
  end

  if kind == "deleted" then
    return {
      {
        kind = "deleted_file",
        before_start = #before_lines > 0 and 1 or 0,
        before_count = #before_lines,
        after_start = 0,
        after_count = 0,
        before_lines = before_lines,
        after_lines = {},
      },
    }
  end

  local indices = vim.diff(item.before or "", item.after or "", {
    result_type = "indices",
    algorithm = "histogram",
  }) or {}

  for _, hunk in ipairs(indices) do
    local before_start = hunk[1]
    local before_count = hunk[2]
    local after_start = hunk[3]
    local after_count = hunk[4]
    table.insert(hunks, {
      kind = hunk_type(before_count, after_count),
      before_start = before_start,
      before_count = before_count,
      after_start = after_start,
      after_count = after_count,
      before_lines = slice_lines(before_lines, before_start, before_count),
      after_lines = slice_lines(after_lines, after_start, after_count),
    })
  end

  return hunks
end

local hunk_labels = {
  add = "addition",
  change = "change",
  delete = "deletion",
  new_file = "new file",
  deleted_file = "deleted file",
}

local function hunk_title(item, hunk, index, total)
  return string.format("pi hunk %d/%d %s: %s", index, total, hunk_labels[hunk.kind] or "change", item.path)
end

local function changed_items()
  local items = {}
  if M.current and M.current.item then
    table.insert(items, M.current.item)
  end
  for _, item in ipairs(M.queue) do
    table.insert(items, item)
  end
  return items
end

local function item_hunk_count(item)
  return #build_hunks(item)
end

local function review_position()
  if not M.current or not M.current.item then
    return 0, 0, 0, 0
  end

  local total_files = 1 + #M.queue
  local current_hunks = M.current.hunks or build_hunks(M.current.item)
  local current_hunk = clamp(M.current.hunk_index or 1, 1, math.max(#current_hunks, 1))
  local total_hunks = #current_hunks

  for _, item in ipairs(M.queue) do
    total_hunks = total_hunks + item_hunk_count(item)
  end

  return current_hunk, #current_hunks, total_hunks, total_files
end

local function close_badge()
  if M.badge then
    if M.badge.winid and vim.api.nvim_win_is_valid(M.badge.winid) then
      pcall(vim.api.nvim_win_close, M.badge.winid, true)
    end
    if M.badge.bufnr and vim.api.nvim_buf_is_valid(M.badge.bufnr) then
      pcall(vim.api.nvim_buf_delete, M.badge.bufnr, { force = true })
    end
    M.badge = nil
  end
end

local function badge_lines()
  if not M.current or not M.current.item then
    return {}
  end

  local current_hunk, current_hunks, total_hunks, total_files = review_position()
  local path = M.current.item.path or "?"
  local head = string.format(
    " pi  hunk %d/%d  (%d total)  %d file%s  %s ",
    current_hunk,
    current_hunks,
    total_hunks,
    total_files,
    total_files == 1 and "" or "s",
    path
  )
  local hint = " [;a] accept  [;d] reject  [;]]/[;[] jump  [;v] files "
  if not M.files_expanded then
    return { head, hint }
  end

  local lines = { head, hint, " changed files" }
  for index, item in ipairs(changed_items()) do
    local marker = index == 1 and "●" or "○"
    local count = item_hunk_count(item)
    table.insert(lines, string.format(" %s %d hunk%s  %s", marker, count, count == 1 and " " or "s", item.path))
  end
  return lines
end

local function update_badge()
  if not M.current then
    close_badge()
    return
  end

  ensure_inline_highlights()
  local lines = badge_lines()
  if #lines == 0 then
    close_badge()
    return
  end

  local max_height = math.max(vim.o.lines - 6, 1)
  if #lines > max_height then
    local hidden = #lines - max_height + 1
    local truncated = {}
    for i = 1, max_height - 1 do
      table.insert(truncated, lines[i])
    end
    table.insert(truncated, string.format(" … %d more file%s", hidden, hidden == 1 and "" or "s"))
    lines = truncated
  end

  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  local available_width = math.max(vim.o.columns - 4, 1)
  width = math.min(math.max(width, math.min(34, available_width)), available_width)
  local height = #lines
  local row = math.max(vim.o.lines - height - 3, 0)
  local col = math.max(vim.o.columns - width - 3, 0)

  if not M.badge or not M.badge.bufnr or not vim.api.nvim_buf_is_valid(M.badge.bufnr) then
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].buftype = "nofile"
    vim.bo[bufnr].bufhidden = "wipe"
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].modifiable = false
    M.badge = { bufnr = bufnr, winid = nil }
  end

  vim.bo[M.badge.bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(M.badge.bufnr, 0, -1, false, lines)
  vim.bo[M.badge.bufnr].modifiable = false

  local opts = {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    focusable = false,
    zindex = 70,
  }

  if M.badge.winid and vim.api.nvim_win_is_valid(M.badge.winid) then
    pcall(vim.api.nvim_win_set_config, M.badge.winid, opts)
  else
    M.badge.winid = vim.api.nvim_open_win(M.badge.bufnr, false, opts)
  end

  pcall(vim.api.nvim_set_option_value, "winhl", "Normal:PiDiffBadge,FloatBorder:PiDiffBadgeBorder", { win = M.badge.winid })
end

local function hunk_anchor(hunk, line_count)
  if hunk.after_count > 0 then
    return math.max(hunk.after_start - 1, 0), true
  end
  if hunk.after_start <= 0 then
    return 0, true
  end
  return math.min(hunk.after_start - 1, math.max(line_count - 1, 0)), false
end

local function add_virtual_lines(bufnr, line_count, hunk, virt_lines)
  if #virt_lines == 0 then
    return
  end
  local anchor, above = hunk_anchor(hunk, line_count)
  pcall(vim.api.nvim_buf_set_extmark, bufnr, inline_ns, anchor, 0, {
    virt_lines = virt_lines,
    virt_lines_above = above,
    right_gravity = false,
  })
end

local function mark_inline_line(bufnr, line, hl, sign)
  pcall(vim.api.nvim_buf_set_extmark, bufnr, inline_ns, line, 0, {
    line_hl_group = hl,
    sign_text = sign,
    sign_hl_group = hl,
    number_hl_group = hl,
    virt_text = { { sign .. " ", hl } },
    virt_text_pos = "inline",
    right_gravity = false,
  })
end

local function render_whole_file(bufnr, current, hunk, index, total)
  local line_count = math.max(vim.api.nvim_buf_line_count(bufnr), 1)
  add_virtual_lines(bufnr, line_count, hunk, { { { hunk_title(current.item, hunk, index, total), "PiDiffCurrent" } } })

  local hl = hunk.kind == "new_file" and "PiDiffAdd" or "PiDiffDelete"
  local sign = hunk.kind == "new_file" and "+" or "-"
  for line = 0, line_count - 1 do
    mark_inline_line(bufnr, line, hl, sign)
  end
end

local function render_inline_diff(bufnr, current)
  ensure_inline_highlights()
  vim.api.nvim_buf_clear_namespace(bufnr, inline_ns, 0, -1)

  local hunks = current.hunks or {}
  local active = current.hunk_index or 1
  local total = #hunks
  if total == 0 then
    return
  end

  local line_count = math.max(vim.api.nvim_buf_line_count(bufnr), 1)
  for index, hunk in ipairs(hunks) do
    if hunk.kind == "new_file" or hunk.kind == "deleted_file" then
      render_whole_file(bufnr, current, hunk, index, total)
      return
    end

    local virt_lines = {}
    if index == active then
      table.insert(virt_lines, { { hunk_title(current.item, hunk, index, total), "PiDiffCurrent" } })
    end
    for _, line in ipairs(hunk.before_lines) do
      table.insert(virt_lines, { { "- " .. line, "PiDiffDelete" } })
    end
    add_virtual_lines(bufnr, line_count, hunk, virt_lines)

    if hunk.after_count > 0 then
      local hl = hunk.kind == "add" and "PiDiffAdd" or "PiDiffChange"
      local sign = hunk.kind == "add" and "+" or "~"
      for i = hunk.after_start, hunk.after_start + hunk.after_count - 1 do
        if i >= 1 then
          mark_inline_line(bufnr, math.min(i - 1, line_count - 1), hl, sign)
        end
      end
    end
  end
end

local function hunk_cursor_span(hunk, line_count)
  if hunk.kind == "new_file" or hunk.kind == "deleted_file" then
    return 1, line_count
  end
  if hunk.after_count > 0 then
    local first = math.max(hunk.after_start, 1)
    return first, math.max(first, hunk.after_start + hunk.after_count - 1)
  end
  local anchor = hunk.after_start <= 0 and 1 or hunk.after_start
  anchor = clamp(anchor, 1, line_count)
  return anchor, anchor
end

local function hunk_index_at_cursor(current)
  if not current.winid or not vim.api.nvim_win_is_valid(current.winid) then
    return current.hunk_index or 1
  end
  local cursor_line = vim.api.nvim_win_get_cursor(current.winid)[1]
  local line_count = 1
  if current.bufnr and vim.api.nvim_buf_is_valid(current.bufnr) then
    line_count = math.max(vim.api.nvim_buf_line_count(current.bufnr), 1)
  end

  for index, hunk in ipairs(current.hunks or {}) do
    local first, last = hunk_cursor_span(hunk, line_count)
    if cursor_line >= first and cursor_line <= last then
      return index
    end
  end
  return current.hunk_index or 1
end

local function focus_hunk(current)
  if not current.winid or not vim.api.nvim_win_is_valid(current.winid) then
    return
  end

  local hunk = current.hunks and current.hunks[current.hunk_index]
  if not hunk then
    return
  end

  local line_count = 1
  if current.bufnr and vim.api.nvim_buf_is_valid(current.bufnr) then
    line_count = math.max(vim.api.nvim_buf_line_count(current.bufnr), 1)
  end
  local first = hunk_cursor_span(hunk, line_count)
  pcall(vim.api.nvim_win_set_cursor, current.winid, { clamp(first, 1, line_count), 0 })
end

local function set_safe_buffer(winid, current)
  if not winid or not vim.api.nvim_win_is_valid(winid) then
    return
  end

  local item = current.item
  local kind = current.kind
  pcall(vim.api.nvim_set_current_win, winid)

  if (kind == "deleted" or kind == "new") and item and util.path_exists(item.abs_path) then
    pcall(set_file_buffer_in_window, winid, item.abs_path)
    return
  end

  if kind == "deleted" or (kind == "new" and item and not util.path_exists(item.abs_path)) then
    if current.origin_buf and vim.api.nvim_buf_is_valid(current.origin_buf) and current.origin_buf ~= current.bufnr then
      local origin_name = vim.api.nvim_buf_get_name(current.origin_buf)
      local origin_is_missing_review_file = item and origin_name == item.abs_path and not util.path_exists(item.abs_path)
      if not origin_is_missing_review_file then
        pcall(vim.api.nvim_win_set_buf, winid, current.origin_buf)
        return
      end
    end
    local fallback = vim.api.nvim_create_buf(true, false)
    pcall(vim.api.nvim_win_set_buf, winid, fallback)
  end
end

local function close_current()
  local current = M.current
  if not current then
    return
  end
  M.current = nil

  if current.bufnr and vim.api.nvim_buf_is_valid(current.bufnr) then
    pcall(vim.api.nvim_buf_clear_namespace, current.bufnr, inline_ns, 0, -1)
  end
  close_badge()

  local winid = current.winid
  if winid and vim.api.nvim_win_is_valid(winid) then
    set_safe_buffer(winid, current)
    restore_cursor(winid, current.origin_cursor)
  elseif current.origin_win and vim.api.nvim_win_is_valid(current.origin_win) then
    set_safe_buffer(current.origin_win, current)
    restore_cursor(current.origin_win, current.origin_cursor)
  end

  local should_delete_review_buf = current.kind == "deleted"
    or (current.kind == "new" and current.item and not util.path_exists(current.item.abs_path))
  if should_delete_review_buf and current.bufnr and vim.api.nvim_buf_is_valid(current.bufnr) and not buffer_visible(current.bufnr) then
    pcall(vim.api.nvim_buf_delete, current.bufnr, { force = true })
  end
end

local function refresh_current_view(current, preferred_hunk)
  if not current or not current.item then
    return 0
  end
  local winid = current.winid or current.origin_win
  if not winid or not vim.api.nvim_win_is_valid(winid) then
    return 0
  end

  local old_buf = current.bufnr
  if old_buf and vim.api.nvim_buf_is_valid(old_buf) then
    pcall(vim.api.nvim_buf_clear_namespace, old_buf, inline_ns, 0, -1)
  end

  current.kind = review_kind(current.item)
  current.hunks = build_hunks(current.item)
  if #current.hunks == 0 then
    return 0
  end
  current.hunk_index = clamp(preferred_hunk or current.hunk_index or 1, 1, #current.hunks)

  local bufnr = open_file_in_window(winid, current.item)
  current.bufnr = bufnr
  render_inline_diff(bufnr, current)
  focus_hunk(current)
  update_badge()

  if old_buf and old_buf ~= bufnr and vim.api.nvim_buf_is_valid(old_buf) and current.kind ~= "modified" then
    local name = vim.api.nvim_buf_get_name(old_buf)
    if name:match("%(pi deleted file review%)$") then
      pcall(vim.api.nvim_buf_delete, old_buf, { force = true })
    end
  end

  return #current.hunks
end

local function open_item(item, preferred_hunk)
  local origin_win = find_main_editor_window() or vim.api.nvim_get_current_win()
  local origin_buf = vim.api.nvim_win_get_buf(origin_win)
  local origin_cursor = vim.api.nvim_win_get_cursor(origin_win)
  local kind = review_kind(item)

  M.current = {
    mode = "inline",
    item = item,
    bufnr = nil,
    winid = origin_win,
    origin_win = origin_win,
    origin_buf = origin_buf,
    origin_cursor = origin_cursor,
    kind = kind,
    hunk_index = 1,
    hunks = {},
  }

  vim.wo[origin_win].wrap = false
  local hunk_count = refresh_current_view(M.current, preferred_hunk or 1)
  if hunk_count == 0 then
    close_current()
    M.open_next()
    return
  end

  util.notify(string.format(
    "Reviewing %s inline (%d hunk%s, %d file%s queued)",
    item.path,
    hunk_count,
    hunk_count == 1 and "" or "s",
    #M.queue,
    #M.queue == 1 and "" or "s"
  ))
end

local function complete_or_continue(preferred_hunk)
  local current = M.current
  if not current then
    return
  end

  current.hunks = build_hunks(current.item)
  if #current.hunks == 0 then
    close_current()
    if #M.queue > 0 then
      M.open_next()
    else
      util.notify("pi review complete", vim.log.levels.INFO)
    end
    return
  end

  local next_hunk = math.min(preferred_hunk or current.hunk_index or 1, #current.hunks)
  refresh_current_view(current, next_hunk)
  util.notify(string.format(
    "pi review: %d hunk%s remaining in %s",
    #current.hunks,
    #current.hunks == 1 and "" or "s",
    current.item.path
  ), vim.log.levels.INFO)
end

-- Hunk review has two moving sides:
--   before = accepted baseline
--   after  = current file content with unresolved pi changes
-- Accepting patches before forward. Rejecting patches after backward.
local function accept_hunk(item, hunk)
  if hunk.kind == "new_file" or hunk.kind == "deleted_file" then
    item.before = item.after
    return true
  end

  local before_line_count = #split_content(item.before)
  local final_newline = content_has_final_newline(item.before)
  if hunk_touches_eof(hunk.before_start, hunk.before_count, before_line_count) then
    final_newline = content_has_final_newline(item.after)
  end
  item.before = replace_content_range(
    item.before or "",
    hunk.before_start,
    hunk.before_count,
    hunk.after_lines,
    final_newline
  )
  return true
end

local function reject_hunk(item, hunk)
  if hunk.kind == "new_file" then
    if not write_review_content(item, nil) then
      return false
    end
    item.after = nil
    return true
  end

  if hunk.kind == "deleted_file" then
    if not write_review_content(item, item.before or "") then
      return false
    end
    item.after = item.before or ""
    return true
  end

  local after_line_count = #split_content(item.after)
  local final_newline = content_has_final_newline(item.after)
  if hunk_touches_eof(hunk.after_start, hunk.after_count, after_line_count) then
    final_newline = content_has_final_newline(item.before)
  end
  local next_after = replace_content_range(
    item.after or "",
    hunk.after_start,
    hunk.after_count,
    hunk.before_lines,
    final_newline
  )

  if not write_review_content(item, next_after) then
    return false
  end
  item.after = next_after
  return true
end

local function queued_index(abs_path)
  for i, item in ipairs(M.queue) do
    if item.abs_path == abs_path then
      return i, item
    end
  end
  return nil, nil
end

local function current_or_queued_item(abs_path)
  if M.current and M.current.item and M.current.item.abs_path == abs_path then
    return M.current.item, "current"
  end
  local idx, item = queued_index(abs_path)
  if item then
    return item, "queue", idx
  end
  return nil, nil, nil
end

local function upsert_review_item(item)
  if not item then
    return 0
  end

  if M.current and M.current.item and M.current.item.abs_path == item.abs_path then
    local existing = M.current.item
    existing.after = item.after
    existing.path = item.path
    existing.root = item.root
    if existing.before == existing.after then
      write_review_content(existing, existing.after)
      close_current()
      M.open_next()
      return 0
    end
    refresh_current_view(M.current, M.current.hunk_index)
    return 1
  end

  local idx, existing = queued_index(item.abs_path)
  if existing then
    existing.after = item.after
    existing.path = item.path
    existing.root = item.root
    if existing.before == existing.after then
      write_review_content(existing, existing.after)
      table.remove(M.queue, idx)
      update_badge()
      return 0
    end
    update_badge()
    return 1
  end

  if item.before == item.after then
    return 0
  end

  table.insert(M.queue, item)
  if config.get().diff.auto_open and not M.current then
    M.open_next()
  else
    update_badge()
    util.notify(string.format("pi review queue: %d file(s)", #M.queue), vim.log.levels.INFO)
  end
  return 1
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
  local lines = split_content(text)
  local insert_lines = split_content(insert_text)
  local idx = math.min(math.max(line_nr, 1), #lines + 1)
  for i = #insert_lines, 1, -1 do
    table.insert(lines, idx, insert_lines[i])
  end
  local trailing = text and text:sub(-1) == "\n"
  return join_lines(lines, trailing or insert_text:sub(-1) == "\n"), true
end

local function apply_edit_args(before, args)
  if before == nil or type(args) ~= "table" or type(args.edits) ~= "table" then
    return nil
  end
  local after = before
  for _, edit in ipairs(args.edits) do
    local old_text = edit.oldText or edit.old_text or ""
    local new_text = edit.newText or edit.new_text or ""
    local ok
    after, ok = replace_once(after, old_text, new_text)
    if not ok then
      return nil
    end
  end
  return after
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

local function tool_after(event, base, abs_path)
  local args = event.arguments or {}
  local tool = event.toolName

  if tool == "write" and args.content ~= nil then
    return args.content
  end
  if tool == "delete" or tool == "remove" then
    return nil
  end
  if tool == "edit" then
    local applied = apply_edit_args(base, args)
    if applied ~= nil then
      return applied
    end
  end
  return util.read_file(abs_path)
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

  local existing = current_or_queued_item(abs_path)
  local before
  if existing then
    before = existing.before
  elseif snapshot and snapshot.contents then
    before = snapshot.contents[path]
  elseif event.before_captured then
    before = event.before
  end

  local base = existing and existing.after or before
  local after = tool_after(event, base, abs_path)

  if before == nil and event.toolName == "edit" then
    before = reverse_edit_args(after, args, event.details)
  end

  return upsert_review_item({
    root = root,
    path = path,
    abs_path = abs_path,
    before = before,
    after = after,
  })
end

function M.enqueue_review(snapshot)
  if not config.get().diff.enabled or not snapshot then
    return 0
  end
  local touched = candidate_changes(snapshot)
  if #touched == 0 then
    return 0
  end

  local added = 0
  for _, item in ipairs(touched) do
    added = added + upsert_review_item(item)
  end
  return added
end

function M.open_next()
  if M.current or #M.queue == 0 then
    return
  end
  open_item(table.remove(M.queue, 1))
end

function M.next_hunk()
  if not M.current then
    M.open_next()
    return
  end

  M.current.hunks = build_hunks(M.current.item)
  if #M.current.hunks == 0 then
    complete_or_continue(M.current.hunk_index)
    return
  end

  if (M.current.hunk_index or 1) < #M.current.hunks then
    refresh_current_view(M.current, (M.current.hunk_index or 1) + 1)
    return
  end

  if #M.queue == 0 then
    refresh_current_view(M.current, #M.current.hunks)
    util.notify("pi review: already at last hunk", vim.log.levels.INFO)
    return
  end

  local next_item = table.remove(M.queue, 1)
  table.insert(M.queue, M.current.item)
  close_current()
  open_item(next_item, 1)
end

function M.prev_hunk()
  if not M.current then
    M.open_next()
    return
  end

  M.current.hunks = build_hunks(M.current.item)
  if #M.current.hunks == 0 then
    complete_or_continue(M.current.hunk_index)
    return
  end

  if (M.current.hunk_index or 1) > 1 then
    refresh_current_view(M.current, (M.current.hunk_index or 1) - 1)
    return
  end

  if #M.queue == 0 then
    refresh_current_view(M.current, 1)
    util.notify("pi review: already at first hunk", vim.log.levels.INFO)
    return
  end

  local prev_item = table.remove(M.queue, #M.queue)
  table.insert(M.queue, 1, M.current.item)
  close_current()
  open_item(prev_item, math.huge)
end

function M.toggle_files()
  if not M.current then
    util.notify("No active pi diff review", vim.log.levels.WARN)
    return
  end
  M.files_expanded = not M.files_expanded
  update_badge()
end

function M.accept_current()
  if not M.current then
    util.notify("No active pi diff review", vim.log.levels.WARN)
    return
  end
  if not can_apply_item(M.current.item) then
    return
  end

  M.current.hunks = build_hunks(M.current.item)
  M.current.hunk_index = clamp(hunk_index_at_cursor(M.current), 1, math.max(#M.current.hunks, 1))
  local hunk = M.current.hunks[M.current.hunk_index]
  if not hunk then
    complete_or_continue(M.current.hunk_index)
    return
  end

  local next_index = M.current.hunk_index
  if accept_hunk(M.current.item, hunk) then
    complete_or_continue(next_index)
  end
end

function M.deny_current()
  if not M.current then
    util.notify("No active pi diff review", vim.log.levels.WARN)
    return
  end
  if not can_apply_item(M.current.item) then
    return
  end

  M.current.hunks = build_hunks(M.current.item)
  M.current.hunk_index = clamp(hunk_index_at_cursor(M.current), 1, math.max(#M.current.hunks, 1))
  local hunk = M.current.hunks[M.current.hunk_index]
  if not hunk then
    complete_or_continue(M.current.hunk_index)
    return
  end

  local next_index = M.current.hunk_index
  if reject_hunk(M.current.item, hunk) then
    complete_or_continue(next_index)
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
    if not can_apply_item(item) then
      return 0
    end
  end
  for _, item in ipairs(restore_items) do
    if not restore_path(item) then
      return 0
    end
  end
  close_current()

  util.notify(string.format("pi cascade rejected %d file(s)", #restore_items), vim.log.levels.INFO)
  return #restore_items
end

function M.clear()
  M.queue = {}
  close_current()
end

local badge_resize_group = vim.api.nvim_create_augroup("PiDiffBadgeResize", { clear = true })
vim.api.nvim_create_autocmd("VimResized", {
  group = badge_resize_group,
  callback = function()
    update_badge()
  end,
})

return M
