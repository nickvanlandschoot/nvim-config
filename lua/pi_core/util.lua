local M = {}

local function system_sync(cmd, opts)
  local result = vim.system(cmd, vim.tbl_extend("keep", opts or {}, { text = true })):wait()
  return result
end

function M.notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO)
  end)
end

function M.append_file(path, lines)
  if not path or path == "" then
    return
  end
  local fd = io.open(path, "a")
  if not fd then
    return
  end
  for _, line in ipairs(lines) do
    fd:write(line)
    if not line:match("\n$") then
      fd:write("\n")
    end
  end
  fd:close()
end

function M.read_file(path)
  local fd = io.open(path, "rb")
  if not fd then
    return nil
  end
  local content = fd:read("*a")
  fd:close()
  return content
end

function M.write_file(path, content)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local fd = io.open(path, "wb")
  if not fd then
    return false
  end
  fd:write(content)
  fd:close()
  return true
end

function M.hash_string(s)
  local hash = 5381
  for i = 1, #s do
    hash = bit.band(((hash * 33) + s:byte(i)), 0x7fffffff)
  end
  return string.format("%x", hash)
end

function M.cwd()
  return vim.fn.getcwd()
end

function M.project_session_dir(subdir)
  local cwd = M.cwd()
  local key = M.hash_string(cwd)
  local dir = vim.fn.stdpath("state") .. "/" .. (subdir or "pi-nvim") .. "/" .. key
  vim.fn.mkdir(dir, "p")
  return dir
end

function M.systemlist(cmd, opts)
  local result = system_sync(cmd, opts)
  if result.code ~= 0 then
    return {}, result.stderr
  end
  local out = result.stdout or ""
  if out == "" then
    return {}, nil
  end
  return vim.split(vim.trim(out), "\n", { plain = true, trimempty = true }), nil
end

function M.systemtext(cmd, opts)
  local result = system_sync(cmd, opts)
  if result.code ~= 0 then
    return nil, result.stderr ~= "" and result.stderr or ("command failed: " .. table.concat(cmd, " "))
  end
  return result.stdout or "", nil
end

function M.shellescape(path)
  return vim.fn.shellescape(path)
end

function M.filetype_for_path(path)
  if vim.filetype and vim.filetype.match then
    local ok, ft = pcall(vim.filetype.match, { filename = path })
    if ok and ft and ft ~= "" then
      return ft
    end
  end
  return vim.fn.fnamemodify(path, ":e")
end

function M.normalize_path(path)
  if not path or path == "" then
    return nil
  end
  return vim.fn.fnamemodify(vim.fn.expand(path), ":p")
end

function M.path_exists(path)
  return path and vim.uv.fs_stat(path) ~= nil
end

function M.is_dir(path)
  local stat = path and vim.uv.fs_stat(path) or nil
  return stat and stat.type == "directory" or false
end

function M.is_file(path)
  local stat = path and vim.uv.fs_stat(path) or nil
  return stat and stat.type == "file" or false
end

function M.sorted_session_files(dir)
  local files = vim.fn.glob(dir .. "/*.jsonl", false, true)
  table.sort(files, function(a, b)
    local sa = vim.uv.fs_stat(a)
    local sb = vim.uv.fs_stat(b)
    local ma = sa and sa.mtime and sa.mtime.sec or 0
    local mb = sb and sb.mtime and sb.mtime.sec or 0
    if ma == mb then
      return a > b
    end
    return ma > mb
  end)
  return files
end

return M
