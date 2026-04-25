local config = require("pi_core.config")
local util = require("pi_core.util")

local M = {
  bufnr = nil,
  winid = nil,
  jobid = nil,
  mode = "default",
  hooks = {},
  session_file = nil,
  session_dir = nil,
  watch_timer = nil,
  watch_state = nil,
}

local function width()
  local w = config.get().panel.width or 0.36
  if w < 1 then
    return math.max(40, math.floor(vim.o.columns * w))
  end
  return w
end

local function session_dir()
  if M.session_dir then
    return M.session_dir
  end
  local cfg = config.get()
  local suffix = cfg.rpc.chat_session_subdir or (cfg.rpc.session_subdir .. "-chat-" .. vim.fn.getpid())
  M.session_dir = util.project_session_dir(suffix)
  return M.session_dir
end

local function base_cmd()
  local cfg = config.get()
  local cmd = {
    cfg.rpc.command,
    "--session-dir",
    session_dir(),
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

  local model = config.get().chat_model or {}
  if model.provider and model.id then
    table.insert(cmd, "--provider")
    table.insert(cmd, model.provider)
    table.insert(cmd, "--model")
    table.insert(cmd, model.id)
  end
  if model.thinking and model.thinking ~= "" then
    table.insert(cmd, "--thinking")
    table.insert(cmd, model.thinking)
  end

  return cmd
end

local function build_cmd(mode)
  local cmd = base_cmd()
  if mode == "continue" then
    table.insert(cmd, 2, "-c")
  elseif mode == "resume" then
    table.insert(cmd, 2, "-r")
  end
  return cmd
end

local function is_job_running()
  return M.jobid and vim.fn.jobwait({ M.jobid }, 0)[1] == -1
end

local function is_visible()
  return M.winid and vim.api.nvim_win_is_valid(M.winid)
end

local function ensure_window(focus)
  if is_visible() then
    if focus then
      vim.api.nvim_set_current_win(M.winid)
      vim.cmd("startinsert")
    end
    return M.winid
  end

  local split = config.get().panel.split
  if split == "left" then
    vim.cmd("topleft vsplit")
  else
    vim.cmd("botright vsplit")
  end
  M.winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(M.winid, width())
  vim.wo[M.winid].number = false
  vim.wo[M.winid].relativenumber = false
  vim.wo[M.winid].signcolumn = "no"
  vim.wo[M.winid].winfixwidth = true
  vim.wo[M.winid].wrap = false

  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
    vim.api.nvim_win_set_buf(M.winid, M.bufnr)
  end

  if focus then
    vim.cmd("startinsert")
  else
    vim.cmd("wincmd p")
  end

  return M.winid
end

local function send_literal(bufnr, text)
  local jobid = vim.b[bufnr].terminal_job_id or vim.bo[bufnr].channel or M.jobid
  if jobid then
    vim.fn.chansend(jobid, text)
  end
end

local function latest_session_file()
  local files = util.sorted_session_files(session_dir())
  return files[1]
end

local function scan_session_file(fire_callbacks)
  local file = latest_session_file()
  if not file or file == "" then
    return
  end

  local content = util.read_file(file)
  if not content or content == "" then
    return
  end

  local user_messages = {}
  local assistants = {}
  local tool_calls = {}
  local tool_call_by_id = {}
  local edit_results = {}

  for line in content:gmatch("[^\n]+") do
    local ok, entry = pcall(vim.json.decode, line)
    if ok and type(entry) == "table" and entry.type == "message" and entry.message and entry.id then
      local msg = entry.message
      if msg.role == "user" then
        table.insert(user_messages, entry.id)
      elseif msg.role == "assistant" then
        table.insert(assistants, entry.id)
        for _, part in ipairs(msg.content or {}) do
          if type(part) == "table" and part.type == "toolCall" and (part.name == "edit" or part.name == "write") and part.id then
            local call = {
              id = part.id,
              toolName = part.name,
              arguments = part.arguments or {},
            }
            tool_call_by_id[part.id] = call
            table.insert(tool_calls, call)
          end
        end
      elseif msg.role == "toolResult" and (msg.toolName == "edit" or msg.toolName == "write") then
        local call = tool_call_by_id[msg.toolCallId] or {}
        table.insert(edit_results, {
          id = entry.id,
          toolCallId = msg.toolCallId,
          toolName = msg.toolName,
          arguments = call.arguments or {},
          details = msg.details or {},
          isError = msg.isError or false,
        })
      end
    end
  end

  if M.session_file ~= file then
    M.session_file = file
    M.watch_state = { users = {}, assistants = {}, tool_calls = {}, edit_results = {} }
    for _, id in ipairs(user_messages) do
      M.watch_state.users[id] = true
    end
    for _, id in ipairs(assistants) do
      M.watch_state.assistants[id] = true
    end
    for _, item in ipairs(tool_calls) do
      M.watch_state.tool_calls[item.id] = true
    end
    for _, item in ipairs(edit_results) do
      M.watch_state.edit_results[item.id] = true
    end
    if M.hooks.on_session_change then
      pcall(M.hooks.on_session_change, file)
    end
    if fire_callbacks and #user_messages > 0 and M.hooks.on_user_message then
      pcall(M.hooks.on_user_message, {
        id = user_messages[#user_messages],
        session_file = file,
        initial = true,
      })
    end
    if fire_callbacks and #tool_calls > 0 and M.hooks.on_tool_call then
      local item = tool_calls[#tool_calls]
      pcall(M.hooks.on_tool_call, vim.tbl_extend("force", item, {
        session_file = file,
        initial = true,
      }))
    end
    if fire_callbacks and #edit_results > 0 and M.hooks.on_tool_result then
      local item = edit_results[#edit_results]
      pcall(M.hooks.on_tool_result, vim.tbl_extend("force", item, {
        session_file = file,
        initial = true,
      }))
    elseif fire_callbacks and #assistants > 0 and M.hooks.on_assistant_message then
      pcall(M.hooks.on_assistant_message, {
        id = assistants[#assistants],
        session_file = file,
        initial = true,
      })
    end
    return
  end

  M.watch_state = M.watch_state or { users = {}, assistants = {}, tool_calls = {}, edit_results = {} }
  M.watch_state.tool_calls = M.watch_state.tool_calls or {}
  M.watch_state.edit_results = M.watch_state.edit_results or {}

  for _, id in ipairs(user_messages) do
    if not M.watch_state.users[id] then
      M.watch_state.users[id] = true
      if fire_callbacks and M.hooks.on_user_message then
        pcall(M.hooks.on_user_message, { id = id, session_file = file })
      end
    end
  end
  for _, item in ipairs(tool_calls) do
    if not M.watch_state.tool_calls[item.id] then
      M.watch_state.tool_calls[item.id] = true
      if fire_callbacks and M.hooks.on_tool_call then
        pcall(M.hooks.on_tool_call, vim.tbl_extend("force", item, { session_file = file }))
      end
    end
  end
  for _, item in ipairs(edit_results) do
    if not M.watch_state.edit_results[item.id] then
      M.watch_state.edit_results[item.id] = true
      if fire_callbacks and M.hooks.on_tool_result then
        pcall(M.hooks.on_tool_result, vim.tbl_extend("force", item, { session_file = file }))
      end
    end
  end
  for _, id in ipairs(assistants) do
    if not M.watch_state.assistants[id] then
      M.watch_state.assistants[id] = true
      if fire_callbacks and M.hooks.on_assistant_message then
        pcall(M.hooks.on_assistant_message, { id = id, session_file = file })
      end
    end
  end
end

local function stop_watcher()
  if M.watch_timer then
    M.watch_timer:stop()
    M.watch_timer:close()
    M.watch_timer = nil
  end
end

local function start_watcher()
  stop_watcher()
  scan_session_file(false)
  local timer = vim.uv.new_timer()
  if not timer then
    return
  end
  timer:start(250, 250, vim.schedule_wrap(function()
    scan_session_file(true)
  end))
  M.watch_timer = timer
end

local function setup_terminal_buffer(bufnr)
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "pi-terminal"
  vim.keymap.set("t", "<Esc><Esc>", [[<C-\\><C-n>]], {
    buffer = bufnr,
    silent = true,
    desc = "Exit pi terminal mode",
  })

  -- Prevent global terminal-mode AI mappings from hijacking literal prompt text
  -- inside the pi chat terminal, especially mappings like <leader>ot where
  -- <leader> is space and normal typing may include " ot".
  vim.keymap.set("t", "<leader>ot", function()
    send_literal(bufnr, (vim.g.mapleader or "\\") .. "ot")
  end, {
    buffer = bufnr,
    silent = true,
    desc = "Pass literal <leader>ot to pi terminal",
  })

  vim.keymap.set("t", "<CR>", function()
    if M.hooks.on_submit then
      pcall(M.hooks.on_submit)
    end
    send_literal(bufnr, "\r")
  end, {
    buffer = bufnr,
    silent = true,
    desc = "Submit pi terminal input with review tracking",
  })
end

local function start_new(mode, focus)
  ensure_window(focus)
  vim.cmd("enew")
  local bufnr = vim.api.nvim_get_current_buf()
  local cmd = build_cmd(mode)
  local jobid = vim.fn.termopen(cmd, {
    cwd = util.cwd(),
    on_exit = function()
      vim.schedule(function()
        M.jobid = nil
        stop_watcher()
      end)
    end,
  })
  M.bufnr = bufnr
  M.jobid = jobid
  M.mode = mode or "default"
  M.session_file = nil
  M.watch_state = nil
  setup_terminal_buffer(bufnr)
  pcall(vim.api.nvim_buf_set_name, bufnr, "pi://terminal")
  start_watcher()
  if focus then
    vim.cmd("startinsert")
  end
end

function M.open(opts)
  opts = opts or {}
  local mode = opts.mode or "default"
  local focus = opts.focus ~= false

  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) and is_job_running() and M.mode == mode then
    ensure_window(focus)
    return
  end

  M.close({ force = true, keep_window = false })
  start_new(mode, focus)
end

function M.toggle()
  if is_visible() then
    local winid = M.winid
    M.winid = nil
    pcall(vim.api.nvim_win_close, winid, true)
    return
  end
  M.open({ mode = M.mode or "default", focus = true })
end

function M.focus()
  M.open({ mode = M.mode or "default", focus = true })
end

function M.send(text, submit)
  if not text or text == "" then
    return
  end
  M.open({ mode = M.mode or "default", focus = true })
  if M.jobid then
    vim.fn.chansend(M.jobid, text)
    if submit ~= false then
      vim.fn.chansend(M.jobid, "\r")
    end
  end
end

function M.interrupt()
  if M.jobid and is_job_running() then
    pcall(vim.fn.chansend, M.jobid, "\003")
    return true
  end
  return false
end

function M.close(opts)
  opts = opts or {}
  M.flush_session()
  stop_watcher()
  if M.jobid and is_job_running() then
    pcall(vim.fn.jobstop, M.jobid)
  end
  M.jobid = nil
  M.session_file = nil
  M.watch_state = nil
  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
    pcall(vim.api.nvim_buf_delete, M.bufnr, { force = true })
  end
  M.bufnr = nil
  if not opts.keep_window and M.winid and vim.api.nvim_win_is_valid(M.winid) then
    pcall(vim.api.nvim_win_close, M.winid, true)
  end
  M.winid = nil
end

function M.new_session()
  M.open({ mode = "default", focus = true })
end

function M.continue_session()
  M.open({ mode = "continue", focus = true })
end

function M.resume_session()
  M.open({ mode = "resume", focus = true })
end

function M.is_visible()
  return is_visible()
end

function M.set_hooks(hooks)
  M.hooks = hooks or {}
end

function M.flush_session()
  scan_session_file(true)
end

function M.is_running()
  return is_job_running()
end

function M.get_bufnr()
  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
    return M.bufnr
  end
  return nil
end

function M.is_terminal_buffer(bufnr)
  return M.get_bufnr() ~= nil and bufnr == M.get_bufnr()
end

return M
