local config = require("pi_core.config")

local M = {
  bufnr = nil,
  winid = nil,
}

local function ensure_initialized(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 or (#lines == 1 and lines[1] == "") then
    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "pi.nvim panel",
      "",
      "- PiAsk / PiAskSelection to send a prompt",
      "- PiAddCurrentFile / PiAddPath to stage context",
      "- PiSessions / PiSessionNew for session control",
      "",
    })
    vim.bo[bufnr].modifiable = false
  end
end

local function ensure_buffer()
  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
    return M.bufnr
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "markdown"
  vim.bo[bufnr].modifiable = true
  pcall(vim.api.nvim_buf_set_name, bufnr, "pi-panel")
  ensure_initialized(bufnr)
  M.bufnr = bufnr
  return bufnr
end

local function desired_width()
  local width = config.get().panel.width or 0.36
  if width < 1 then
    return math.max(40, math.floor(vim.o.columns * width))
  end
  return width
end

function M.is_visible()
  return M.winid and vim.api.nvim_win_is_valid(M.winid)
end

function M.open(opts)
  opts = opts or {}
  local bufnr = ensure_buffer()
  ensure_initialized(bufnr)
  if M.is_visible() then
    if opts.focus then
      vim.api.nvim_set_current_win(M.winid)
    end
    return
  end

  local split = config.get().panel.split
  if split == "left" then
    vim.cmd("topleft vsplit")
  else
    vim.cmd("botright vsplit")
  end

  M.winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(M.winid, desired_width())
  vim.api.nvim_win_set_buf(M.winid, bufnr)
  vim.wo[M.winid].number = false
  vim.wo[M.winid].relativenumber = false
  vim.wo[M.winid].signcolumn = "no"
  vim.wo[M.winid].wrap = true
  vim.wo[M.winid].cursorline = false
  vim.wo[M.winid].winfixwidth = true

  if not opts.focus then
    vim.cmd("wincmd p")
  end
end

function M.focus()
  M.open({ focus = true })
end

function M.toggle()
  if M.is_visible() then
    local winid = M.winid
    M.winid = nil
    pcall(vim.api.nvim_win_close, winid, true)
    return
  end
  M.open({ focus = config.get().panel.focus_on_open })
end

local function scroll_bottom()
  if M.is_visible() then
    vim.api.nvim_win_call(M.winid, function()
      vim.cmd("normal! G")
    end)
  end
end

function M.append(lines)
  local bufnr = ensure_buffer()
  if type(lines) == "string" then
    lines = vim.split(lines, "\n", { plain = true })
  end
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  scroll_bottom()
end

function M.append_text(text)
  local bufnr = ensure_buffer()
  local existing = vim.api.nvim_buf_get_lines(bufnr, -2, -1, false)
  vim.bo[bufnr].modifiable = true
  if #existing == 0 then
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { text })
  else
    existing[1] = existing[1] .. text
    vim.api.nvim_buf_set_lines(bufnr, -2, -1, false, existing)
  end
  vim.bo[bufnr].modifiable = false
  scroll_bottom()
end

function M.set_header(lines)
  local bufnr = ensure_buffer()
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
end

function M.clear()
  local bufnr = ensure_buffer()
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.bo[bufnr].modifiable = false
  ensure_initialized(bufnr)
end

return M
