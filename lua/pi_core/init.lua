local config = require("pi_core.config")
local context = require("pi_core.context")
local diff = require("pi_core.diff")
local explorer = require("pi_core.explorer")
local panel = require("pi_core.panel")
local rpc = require("pi_core.rpc")
local terminal = require("pi_core.terminal")
local util = require("pi_core.util")

local M = {
  state = {
    session_dir = nil,
    session_file = nil,
    session_name = nil,
    model = nil,
    busy = false,
    current_snapshot = nil,
    current_assistant_started = false,
    chat_snapshot = nil,
    chat_tool_preimages = {},
  },
}

local function default_model()
  local model = config.get().inline_model or {}
  return {
    provider = model.provider,
    model = model.id,
    thinking = model.thinking,
  }
end

local function current_override()
  if vim.g.pi_nvim_inline_provider and vim.g.pi_nvim_inline_model then
    return {
      provider = vim.g.pi_nvim_inline_provider,
      model = vim.g.pi_nvim_inline_model,
      thinking = vim.g.pi_nvim_inline_thinking,
    }
  end
  return nil
end

local function current_inline_model()
  return current_override() or default_model()
end

local function log_lines(lines)
  local path = config.get().log_path
  if not path or path == "" then
    return
  end
  util.append_file(path, lines)
end

local function panel_line(line)
  panel.append({ line })
  log_lines({ line })
end

local function terminal_session_active()
  return terminal.is_running() and terminal.get_bufnr() ~= nil
end

local function capture_chat_snapshot(force)
  if not terminal_session_active() then
    M.state.chat_snapshot = nil
    return nil
  end
  if diff.has_active_review() or #diff.queue > 0 then
    return M.state.chat_snapshot
  end
  if not force and M.state.chat_snapshot then
    return M.state.chat_snapshot
  end
  M.state.chat_snapshot = diff.capture_project_snapshot(util.cwd())
  return M.state.chat_snapshot
end

local function on_chat_submit()
  capture_chat_snapshot(true)
end

local function capture_tool_preimage(event)
  if not event or not event.id then
    return
  end
  local args = event.arguments or {}
  if event.toolName == "bash" then
    M.state.chat_tool_preimages[event.id] = {
      snapshot = diff.capture_project_snapshot(util.cwd()),
    }
    return
  end
  if not args.path or args.path == "" then
    return
  end
  local root = (M.state.chat_snapshot and M.state.chat_snapshot.root) or util.cwd()
  local path = args.path:match("^/") and args.path or (root .. "/" .. args.path)
  path = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
  M.state.chat_tool_preimages[event.id] = {
    before_captured = true,
    before = util.read_file(path),
  }
end

local function queue_chat_review(event, reason)
  if not event then
    return 0
  end
  local added = 0
  if event.toolName == "bash" then
    local preimage = event.toolCallId and M.state.chat_tool_preimages[event.toolCallId] or nil
    if preimage then
      M.state.chat_tool_preimages[event.toolCallId] = nil
    end
    added = diff.enqueue_review((preimage and preimage.snapshot) or M.state.chat_snapshot)
  else
    local preimage = event.toolCallId and M.state.chat_tool_preimages[event.toolCallId] or nil
    if preimage then
      event = vim.tbl_extend("force", event, preimage)
      M.state.chat_tool_preimages[event.toolCallId] = nil
    end
    added = diff.enqueue_tool_review(event, M.state.chat_snapshot)
  end
  if added > 0 then
    util.notify("pi chat edits ready for review" .. (reason and (" (" .. reason .. ")") or ""), vim.log.levels.INFO)
  end
  return added
end

local function refresh_chat_snapshot_after_review()
  if diff.has_active_review() or #diff.queue > 0 then
    return
  end
  if terminal_session_active() then
    capture_chat_snapshot(true)
  else
    M.state.chat_snapshot = nil
  end
end

local function sync_state(callback)
  rpc.request({ type = "get_state" }, function(resp)
    if resp.success and resp.data then
      M.state.session_file = resp.data.sessionFile
      M.state.session_name = resp.data.sessionName
      M.state.model = resp.data.model
      M.state.busy = resp.data.isStreaming or false
    end
    if callback then
      callback(resp)
    end
  end)
end

local function apply_model_override(callback)
  local model = current_inline_model()
  rpc.request({ type = "set_model", provider = model.provider, modelId = model.model }, function(_)
    if model.thinking and model.thinking ~= "" then
      rpc.request({ type = "set_thinking_level", level = model.thinking }, function()
        callback()
      end)
    else
      callback()
    end
  end)
end

local function ensure_started(callback)
  if not M.state.session_dir then
    M.state.session_dir = util.project_session_dir(config.get().rpc.session_subdir)
  end
  panel.open({ focus = false })
  panel_line("[rpc] ensuring pi process")
  rpc.ensure_started({
    session_dir = M.state.session_dir,
    cwd = util.cwd(),
  }, function(ok)
    if not ok then
      panel_line("[rpc] failed to start pi process")
      util.notify("Failed to start pi RPC", vim.log.levels.ERROR)
      return
    end
    apply_model_override(function()
      sync_state(function(resp)
        if resp and resp.success then
          panel_line("[rpc] ready")
        else
          panel_line("[rpc] state sync failed")
        end
        if callback then
          callback()
        end
      end)
    end)
  end)
end

local function current_model_label()
  if M.state.model and M.state.model.provider and M.state.model.id then
    local thinking = vim.g.pi_nvim_inline_thinking or default_model().thinking
    if thinking and thinking ~= "" then
      return string.format("%s / %s (%s)", M.state.model.provider, M.state.model.id, thinking)
    end
    return string.format("%s / %s", M.state.model.provider, M.state.model.id)
  end
  local model = current_inline_model()
  if model.provider and model.model then
    if model.thinking and model.thinking ~= "" then
      return string.format("%s / %s (%s)", model.provider, model.model, model.thinking)
    end
    return string.format("%s / %s", model.provider, model.model)
  end
  return "pi inline default"
end

local function run_bash(command, description, callback)
  ensure_started(function()
    rpc.request({ type = "bash", command = command }, function(resp)
      if not resp.success then
        util.notify("pi bash context failed: " .. (resp.error or "unknown error"), vim.log.levels.ERROR)
        return
      end
      panel_line(string.format("[context] %s", description))
      if callback then
        callback(resp)
      end
    end)
  end)
end

local function send_prompt(prompt_text, opts)
  opts = opts or {}
  ensure_started(function()
    if M.state.busy then
      util.notify("pi is already busy", vim.log.levels.WARN)
      return
    end

    M.state.current_snapshot = diff.capture_snapshot()
    M.state.current_assistant_started = false
    M.state.busy = true

    panel.open({ focus = false })
    panel_line("")
    panel_line("## User")
    panel_line(prompt_text)
    panel_line("")

    rpc.request({ type = "prompt", message = prompt_text }, function(resp)
      if not resp.success then
        M.state.busy = false
        util.notify("pi prompt failed: " .. (resp.error or "unknown error"), vim.log.levels.ERROR)
      end
      if opts.on_sent then
        opts.on_sent(resp)
      end
    end)
  end)
end

local function ask_with_buffer()
  local path = context.current_file_path(0)
  if not path then
    util.notify("PiAsk requires a file-backed buffer", vim.log.levels.ERROR)
    return
  end
  vim.ui.input({ prompt = context.prompt_label(0) }, function(input)
    if not input or input == "" then
      return
    end
    run_bash(context.file_context_bash(path), vim.fn.fnamemodify(path, ":."), function()
      send_prompt(string.format("%s\n\nUse the latest Neovim file context for %s.", input, path))
    end)
  end)
end

local function ask_with_selection()
  local path = context.current_file_path(0)
  if not path then
    util.notify("PiAskSelection requires a file-backed buffer", vim.log.levels.ERROR)
    return
  end
  local selection = context.get_visual_selection()
  if not selection then
    util.notify("No visual selection found", vim.log.levels.ERROR)
    return
  end
  vim.ui.input({ prompt = context.prompt_label(0, "selection") }, function(input)
    if not input or input == "" then
      return
    end
    run_bash(context.selection_context_bash(path, selection), vim.fn.fnamemodify(path, ":.") .. " selection context", function()
      local prompt = string.format(
        "%s\n\nSelected text (%d-%d):\n```\n%s\n```\n\nUse the latest Neovim selection context for surrounding file content.",
        input,
        selection.start_line,
        selection.end_line,
        selection.text
      )
      send_prompt(prompt)
    end)
  end)
end

local function add_path(arg)
  local path = explorer.current_path(arg)
  if not path then
    util.notify("Could not determine path to add", vim.log.levels.ERROR)
    return
  end
  run_bash(context.path_context_bash(path), path, function()
    util.notify("Added to next pi prompt context: " .. vim.fn.fnamemodify(path, ":."), vim.log.levels.INFO)
  end)
end

local function show_log()
  local log_path = config.get().log_path
  if not log_path or log_path == "" then
    util.notify("pi log_path not configured", vim.log.levels.ERROR)
    return
  end
  if vim.fn.filereadable(log_path) == 0 then
    util.notify("pi log file not found at " .. log_path, vim.log.levels.INFO)
    return
  end
  vim.cmd("new")
  vim.cmd("read " .. vim.fn.fnameescape(log_path))
  vim.cmd("1d")
  vim.bo.modifiable = false
  vim.bo.buftype = "nofile"
  vim.bo.filetype = "log"
  vim.cmd("normal! G")
end

local function list_sessions()
  if not M.state.session_dir then
    M.state.session_dir = util.project_session_dir(config.get().rpc.session_subdir)
  end
  return util.sorted_session_files(M.state.session_dir)
end

local function pick_session()
  ensure_started(function()
    sync_state(function()
      local files = list_sessions()
      local items = {
        { label = "+ New session", kind = "new" },
      }
      for _, file in ipairs(files) do
        local current = (file == M.state.session_file) and " *" or ""
        table.insert(items, {
          label = vim.fn.fnamemodify(file, ":t") .. current,
          path = file,
          kind = "switch",
        })
      end
      vim.ui.select(items, {
        prompt = "Select pi session",
        format_item = function(item)
          return item.label
        end,
      }, function(choice)
        if not choice then
          return
        end
        if choice.kind == "new" then
          rpc.request({ type = "new_session" }, function(resp)
            if resp.success then
              sync_state(function()
                panel_line("[session] new session")
              end)
            end
          end)
        elseif choice.path then
          rpc.request({ type = "switch_session", sessionPath = choice.path }, function(resp)
            if resp.success then
              sync_state(function()
                panel_line("[session] switched to " .. vim.fn.fnamemodify(choice.path, ":t"))
              end)
            end
          end)
        end
      end)
    end)
  end)
end

local function new_session()
  ensure_started(function()
    rpc.request({ type = "new_session" }, function(resp)
      if not resp.success then
        util.notify("Failed to create new pi session", vim.log.levels.ERROR)
        return
      end
      sync_state(function()
        panel_line("[session] new session")
      end)
    end)
  end)
end

local function close_session(opts)
  opts = opts or {}
  ensure_started(function()
    local old = M.state.session_file
    rpc.request({ type = "new_session" }, function(resp)
      if not resp.success then
        util.notify("Failed to close current session", vim.log.levels.ERROR)
        return
      end
      if opts.delete and old and util.path_exists(old) then
        os.remove(old)
      end
      sync_state(function()
        panel_line("[session] closed current session")
      end)
    end)
  end)
end

local function cancel()
  if diff.has_active_review() then
    util.notify("A diff review is active. Use PiDiffAccept or PiDiffDeny.", vim.log.levels.WARN)
    return
  end
  ensure_started(function()
    rpc.request({ type = "abort" }, function(_) end)
    rpc.request({ type = "abort_bash" }, function(_) end)
    M.state.busy = false
    panel_line("[abort] requested")
  end)
end

local function status()
  sync_state(function(resp)
    local state = resp.data or {}
    local lines = {
      "pi.nvim local status",
      "  model: " .. current_model_label(),
      "  busy: " .. tostring(state.isStreaming or false),
      "  session: " .. tostring(state.sessionFile or "none"),
      "  session name: " .. tostring(state.sessionName or ""),
      "  panel visible: " .. tostring(panel.is_visible()),
      "  terminal visible: " .. tostring(terminal.is_visible()),
      "  review queue: " .. tostring(#diff.queue + (diff.has_active_review() and 1 or 0)),
    }
    util.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
  end)
end

local function set_model(choice)
  if not choice then
    return
  end

  if choice.provider == nil and choice.model == nil then
    vim.g.pi_nvim_inline_provider = nil
    vim.g.pi_nvim_inline_model = nil
    vim.g.pi_nvim_inline_thinking = nil
    M.state.model = nil
    if rpc.is_running() then
      rpc.stop()
    end
    util.notify("pi inline model reset to default: " .. current_model_label(), vim.log.levels.INFO)
    return
  end

  vim.g.pi_nvim_inline_provider = choice.provider
  vim.g.pi_nvim_inline_model = choice.model
  vim.g.pi_nvim_inline_thinking = choice.thinking or default_model().thinking

  if rpc.is_running() then
    rpc.request({ type = "set_model", provider = choice.provider, modelId = choice.model }, function(resp)
      if resp.success and resp.data then
        M.state.model = resp.data
      end
      local thinking = vim.g.pi_nvim_inline_thinking
      if thinking and thinking ~= "" then
        rpc.request({ type = "set_thinking_level", level = thinking }, function()
          util.notify("pi inline model: " .. current_model_label(), vim.log.levels.INFO)
        end)
      else
        util.notify("pi inline model: " .. current_model_label(), vim.log.levels.INFO)
      end
    end)
  else
    util.notify("pi inline model: " .. current_model_label(), vim.log.levels.INFO)
  end
end

local function model_picker()
  local presets = require("config.pi-models").presets or {}
  local default = default_model()
  local items = {
    {
      name = string.format("Use pi inline default (%s / %s, %s thinking)", default.provider, default.model, default.thinking or "default"),
      provider = nil,
      model = nil,
    },
  }
  for _, preset in ipairs(presets) do
    table.insert(items, preset)
  end
  vim.ui.select(items, {
    prompt = "Select pi inline model",
    format_item = function(item)
      if item.provider == nil and item.model == nil then
        return item.name .. " (current: " .. current_model_label() .. ")"
      end
      return string.format("%s [%s / %s]", item.name, item.provider, item.model)
    end,
  }, set_model)
end

local function chat_toggle()
  if terminal.is_visible() then
    terminal.flush_session()
  end
  terminal.toggle()
end

local function chat_focus()
  terminal.focus()
end

local function chat_new_session()
  terminal.flush_session()
  terminal.new_session()
  M.state.chat_snapshot = nil
  M.state.chat_tool_preimages = {}
end

local function chat_resume_session()
  terminal.flush_session()
  terminal.resume_session()
  M.state.chat_snapshot = nil
  M.state.chat_tool_preimages = {}
end

local function chat_continue_session()
  terminal.flush_session()
  terminal.continue_session()
  M.state.chat_snapshot = nil
  M.state.chat_tool_preimages = {}
end

local function chat_close_session(delete_session)
  terminal.flush_session()
  terminal.close({ force = true })
  M.state.chat_snapshot = nil
  M.state.chat_tool_preimages = {}
  if rpc.is_running() then
    close_session({ delete = delete_session })
  end
end

local function chat_review_now()
  terminal.flush_session()
  if not diff.has_active_review() and #diff.queue == 0 then
    util.notify("No pending pi chat edits to review", vim.log.levels.INFO)
  else
    diff.open_next()
  end
end

local function on_event(event)
  if event.type == "rpc_exit" then
    M.state.busy = false
    panel_line("[rpc] process exited")
    return
  end

  if event.type == "stderr_text" then
    panel_line("[stderr] " .. event.text)
    return
  end

  if event.type == "agent_start" then
    panel_line("## Assistant")
    return
  end

  if event.type == "message_update" then
    local delta = event.assistantMessageEvent or {}
    if delta.type == "text_delta" then
      if not M.state.current_assistant_started then
        panel.append({ "" })
        M.state.current_assistant_started = true
      end
      panel.append_text(delta.delta)
      log_lines({ delta.delta })
    elseif delta.type == "thinking_start" then
      panel_line("[thinking]")
    elseif delta.type == "toolcall_end" and delta.toolCall then
      panel_line(string.format("[toolcall] %s", delta.toolCall.name or "tool"))
    elseif delta.type == "error" then
      panel_line("[error] " .. tostring(delta.reason or "unknown"))
      M.state.busy = false
    end
    return
  end

  if event.type == "tool_execution_start" then
    panel_line(string.format("[tool] %s", event.toolName or "tool"))
    return
  end

  if event.type == "tool_execution_end" then
    panel_line(string.format("[tool done] %s", event.toolName or "tool"))
    return
  end

  if event.type == "agent_end" then
    M.state.busy = false
    M.state.current_assistant_started = false
    panel.append({ "", "---", "" })
    sync_state(function()
      diff.enqueue_review(M.state.current_snapshot)
      M.state.current_snapshot = nil
    end)
    return
  end
end

local function command(name, rhs, opts)
  opts = opts or {}
  if pcall(vim.api.nvim_del_user_command, name) then
  end
  vim.api.nvim_create_user_command(name, rhs, opts)
end

function M.setup(opts)
  config.setup(opts)
  M.state.session_dir = util.project_session_dir(config.get().rpc.session_subdir)
  rpc.add_event_handler(on_event)

  terminal.set_hooks({
    on_submit = on_chat_submit,
    on_user_message = function()
      capture_chat_snapshot(true)
    end,
    on_tool_call = function(event)
      capture_tool_preimage(event)
    end,
    on_tool_result = function(event)
      queue_chat_review(event, "chat " .. tostring(event.toolName or "tool") .. " result")
    end,
  })

  command("PiToggle", function()
    chat_toggle()
  end, { desc = "Toggle pi terminal" })
  command("PiChatToggle", function()
    chat_toggle()
  end, { desc = "Toggle pi chat terminal" })

  command("PiFocus", function()
    chat_focus()
  end, { desc = "Focus pi terminal" })
  command("PiChatFocus", function()
    chat_focus()
  end, { desc = "Focus pi chat terminal" })

  command("PiAsk", function()
    ask_with_buffer()
  end, { desc = "Ask pi with current buffer context" })
  command("PiInlineAsk", function()
    ask_with_buffer()
  end, { desc = "Ask pi inline with current buffer context" })

  command("PiAskSelection", function()
    ask_with_selection()
  end, { range = true, desc = "Ask pi with visual selection context" })
  command("PiInlineAskSelection", function()
    ask_with_selection()
  end, { range = true, desc = "Ask pi inline with visual selection context" })

  command("PiAddCurrentFile", function()
    add_path(context.current_file_path(0))
  end, { desc = "Add current file to next pi prompt context" })
  command("PiInlineAddCurrentFile", function()
    add_path(context.current_file_path(0))
  end, { desc = "Add current file to next pi inline prompt context" })

  command("PiAddPath", function(args)
    add_path(args.args)
  end, {
    desc = "Add current path or explicit path to next pi prompt context",
    nargs = "?",
    complete = "file",
  })
  command("PiInlineAddPath", function(args)
    add_path(args.args)
  end, {
    desc = "Add current path or explicit path to next pi inline prompt context",
    nargs = "?",
    complete = "file",
  })

  command("PiModel", function()
    model_picker()
  end, { desc = "Select pi inline model override" })

  command("PiModelReset", function()
    set_model({ provider = nil, model = nil })
  end, { desc = "Reset pi inline model override" })

  command("PiSessionNew", function()
    new_session()
  end, { desc = "Create a new pi inline session" })
  command("PiChatNew", function()
    chat_new_session()
  end, { desc = "Create a new pi chat session" })

  command("PiSessions", function()
    pick_session()
  end, { desc = "Pick or switch pi session" })
  command("PiInlineSessions", function()
    pick_session()
  end, { desc = "Pick or switch pi inline session" })

  command("PiResume", function()
    pick_session()
  end, { desc = "Resume a pi inline session" })
  command("PiChatResume", function()
    chat_resume_session()
  end, { desc = "Resume a pi chat session" })

  command("PiContinue", function()
    ensure_started(function()
      panel.open({ focus = false })
      status()
    end)
  end, { desc = "Continue pi inline in the current session" })
  command("PiChatContinue", function()
    chat_continue_session()
  end, { desc = "Continue pi chat in the current session" })

  command("PiCloseSession", function(args)
    close_session({ delete = args.bang })
  end, { bang = true, desc = "Close current pi inline session (! also deletes current session file)" })
  command("PiChatClose", function(args)
    chat_close_session(args.bang)
  end, { bang = true, desc = "Close current pi chat session" })
  command("PiChatReview", function()
    chat_review_now()
  end, { desc = "Review edits made by pi chat" })

  command("PiCancel", function()
    cancel()
  end, { desc = "Cancel active pi work" })
  command("PiInlineCancel", function()
    cancel()
  end, { desc = "Cancel active pi inline work" })

  command("PiLog", function()
    show_log()
  end, { desc = "Open pi log" })

  command("PiStatus", function()
    ensure_started(function()
      status()
    end)
  end, { desc = "Show pi status" })

  command("PiDiffAccept", function()
    diff.accept_current()
    refresh_chat_snapshot_after_review()
  end, { desc = "Accept current pi diff hunk" })
  command("PiInlineDiffAccept", function()
    diff.accept_current()
    refresh_chat_snapshot_after_review()
  end, { desc = "Accept current pi inline diff hunk" })

  command("PiDiffDeny", function()
    diff.deny_current()
    refresh_chat_snapshot_after_review()
  end, { desc = "Reject current pi diff hunk" })
  command("PiInlineDiffDeny", function()
    diff.deny_current()
    refresh_chat_snapshot_after_review()
  end, { desc = "Reject current pi inline diff hunk" })

  command("PiDiffNextHunk", function()
    diff.next_hunk()
  end, { desc = "Jump to next pi diff hunk" })
  command("PiInlineDiffNextHunk", function()
    diff.next_hunk()
  end, { desc = "Jump to next pi inline diff hunk" })

  command("PiDiffPrevHunk", function()
    diff.prev_hunk()
  end, { desc = "Jump to previous pi diff hunk" })
  command("PiInlineDiffPrevHunk", function()
    diff.prev_hunk()
  end, { desc = "Jump to previous pi inline diff hunk" })

  command("PiDiffFiles", function()
    diff.toggle_files()
  end, { desc = "Toggle pi diff changed-files badge" })
  command("PiInlineDiffFiles", function()
    diff.toggle_files()
  end, { desc = "Toggle pi inline diff changed-files badge" })

  command("PiDiffCascadeDeny", function()
    terminal.interrupt()
    diff.cascade_deny_current()
    refresh_chat_snapshot_after_review()
  end, { desc = "Reject current pi diff and all queued later diffs" })
  command("PiInlineDiffCascadeDeny", function()
    terminal.interrupt()
    diff.cascade_deny_current()
    refresh_chat_snapshot_after_review()
  end, { desc = "Reject current pi inline diff and all queued later diffs" })
end

return M
