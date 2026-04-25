local config = require("pi_core.config")
local util = require("pi_core.util")

local M = {
  process = nil,
  stdout_tail = "",
  stderr_tail = "",
  next_id = 0,
  pending = {},
  handlers = {},
  state = {},
}

local function dispatch_event(event)
  for _, fn in ipairs(M.handlers) do
    pcall(fn, event)
  end
end

local function handle_response(decoded)
  if not decoded.id then
    return
  end
  local pending = M.pending[decoded.id]
  if not pending then
    return
  end
  M.pending[decoded.id] = nil
  pending(decoded)
end

local function process_line(line)
  if line == "" then
    return
  end
  local ok, decoded = pcall(vim.json.decode, line)
  if not ok or type(decoded) ~= "table" then
    dispatch_event({ type = "stderr_text", text = line })
    return
  end
  if decoded.type == "response" then
    handle_response(decoded)
  else
    dispatch_event(decoded)
  end
end

local function feed_tail(key, chunk)
  if not chunk or chunk == "" then
    return
  end
  M[key] = (M[key] or "") .. chunk
  while true do
    local idx = M[key]:find("\n", 1, true)
    if not idx then
      break
    end
    local line = M[key]:sub(1, idx - 1)
    if line:sub(-1) == "\r" then
      line = line:sub(1, -2)
    end
    M[key] = M[key]:sub(idx + 1)
    process_line(line)
  end
end

local function apply_runtime_settings(on_done)
  local cfg = config.get()
  local remaining = 2
  local function step()
    remaining = remaining - 1
    if remaining == 0 and on_done then
      on_done()
    end
  end

  M.request({ type = "set_auto_retry", enabled = cfg.rpc.auto_retry }, function()
    step()
  end)
  M.request({ type = "set_auto_compaction", enabled = cfg.rpc.auto_compaction }, function()
    step()
  end)
end

function M.add_event_handler(fn)
  table.insert(M.handlers, fn)
end

function M.is_running()
  return M.process ~= nil
end

function M.stop()
  if M.process and not M.process:is_closing() then
    pcall(M.process.kill, M.process, 15)
  end
  M.process = nil
end

function M.request(payload, callback)
  if not M.process then
    callback({ success = false, error = "pi RPC process not running" })
    return
  end
  M.next_id = M.next_id + 1
  local id = tostring(M.next_id)
  payload.id = id
  M.pending[id] = callback
  local ok, err = pcall(M.process.write, M.process, vim.json.encode(payload) .. "\n")
  if not ok then
    M.pending[id] = nil
    callback({ success = false, error = tostring(err) })
  end
end

function M.ensure_started(opts, callback)
  if M.process then
    callback(true)
    return
  end

  opts = opts or {}
  local cfg = config.get()
  local cmd = {
    cfg.rpc.command,
    "--mode",
    "rpc",
    "--session-dir",
    opts.session_dir,
  }

  if not cfg.rpc.extensions then
    table.insert(cmd, "--no-extensions")
  end
  if not cfg.rpc.skills then
    table.insert(cmd, "--no-skills")
  end
  if not cfg.rpc.tools then
    table.insert(cmd, "--no-tools")
  end

  local proc = vim.system(cmd, {
    text = true,
    stdin = true,
    cwd = opts.cwd,
    stdout = vim.schedule_wrap(function(err, data)
      if err then
        dispatch_event({ type = "rpc_error", error = tostring(err) })
        return
      end
      feed_tail("stdout_tail", data)
    end),
    stderr = vim.schedule_wrap(function(err, data)
      if err then
        dispatch_event({ type = "rpc_error", error = tostring(err) })
        return
      end
      feed_tail("stderr_tail", data)
    end),
  }, vim.schedule_wrap(function(result)
    M.process = nil
    for id, pending in pairs(M.pending) do
      M.pending[id] = nil
      pending({ success = false, error = "pi RPC process exited" })
    end
    dispatch_event({ type = "rpc_exit", result = result })
  end))

  M.process = proc
  apply_runtime_settings(function()
    callback(true)
  end)
end

return M
