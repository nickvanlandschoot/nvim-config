local M = {}

local defaults = {
  log_path = "/tmp/pi-nvim.log",
  inline_model = {
    provider = "openai-codex",
    id = "gpt-5.3-codex-spark",
    thinking = "minimal",
  },
  chat_model = {
    provider = nil,
    id = nil,
    thinking = nil,
  },
  panel = {
    split = "right",
    width = 0.36,
    focus_on_open = false,
  },
  rpc = {
    command = "pi",
    session_subdir = "pi-nvim",
    tools = true,
    skills = true,
    extensions = true,
    auto_retry = true,
    auto_compaction = true,
  },
  context = {
    max_file_lines = 300,
    max_selection_context_lines = 40,
    max_directory_files = 80,
    max_directory_depth = 3,
  },
  diff = {
    enabled = true,
    layout = "vertical",
    auto_open = true,
    max_scan_files = 2000,
    max_file_bytes = 1024 * 1024,
  },
}

local state = vim.deepcopy(defaults)

function M.setup(opts)
  state = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  return state
end

function M.get()
  return state
end

return M
