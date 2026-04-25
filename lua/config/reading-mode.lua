-- Reading mode: Zen mode that centers text, hides UI elements, and focuses on content
local M = {}

-- Store original state to restore when toggling off
local original_state = {
  laststatus = nil,
  cmdheight = nil,
  showtabline = nil,
  nvim_tree_open = false,
  left_win = nil,
  right_win = nil,
  original_win = nil,
}

-- Track if reading mode is enabled
M.enabled = false

function M.toggle()
  if M.enabled then
    -- Restore UI elements
    vim.opt.laststatus = original_state.laststatus
    vim.opt.cmdheight = original_state.cmdheight
    vim.opt.showtabline = original_state.showtabline

    -- Close padding windows
    if original_state.left_win and vim.api.nvim_win_is_valid(original_state.left_win) then
      vim.api.nvim_win_close(original_state.left_win, true)
    end
    if original_state.right_win and vim.api.nvim_win_is_valid(original_state.right_win) then
      vim.api.nvim_win_close(original_state.right_win, true)
    end

    -- Restore nvim-tree if it was open
    if original_state.nvim_tree_open then
      vim.cmd("NvimTreeOpen")
    end

    M.enabled = false
    vim.notify("Reading mode disabled", vim.log.levels.INFO)
  else
    -- Save original settings
    original_state.laststatus = vim.o.laststatus
    original_state.cmdheight = vim.o.cmdheight
    original_state.showtabline = vim.o.showtabline

    -- Check if nvim-tree is open
    local nvim_tree_ok, nvim_tree_view = pcall(require, "nvim-tree.view")
    if nvim_tree_ok and nvim_tree_view.is_visible() then
      original_state.nvim_tree_open = true
      vim.cmd("NvimTreeClose")
    else
      original_state.nvim_tree_open = false
    end

    -- Hide UI elements
    vim.opt.laststatus = 0  -- Hide statusline
    vim.opt.cmdheight = 0   -- Hide command line
    vim.opt.showtabline = 0 -- Hide tabline

    -- Create centered layout with padding windows
    original_state.original_win = vim.api.nvim_get_current_win()

    -- Calculate padding for centered text (30% wider than 80 columns)
    local total_width = vim.o.columns
    local text_width = math.floor(80 * 1.30)  -- 104 columns
    local padding = math.floor((total_width - text_width) / 2)

    if padding > 5 then
      -- Create left padding window
      vim.cmd("topleft vnew")
      original_state.left_win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_width(original_state.left_win, padding)

      -- Make it a scratch buffer with no UI elements
      local left_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(original_state.left_win, left_buf)
      vim.api.nvim_set_option_value("number", false, { win = original_state.left_win })
      vim.api.nvim_set_option_value("relativenumber", false, { win = original_state.left_win })
      vim.api.nvim_set_option_value("signcolumn", "no", { win = original_state.left_win })
      vim.api.nvim_set_option_value("foldcolumn", "0", { win = original_state.left_win })
      vim.api.nvim_set_option_value("cursorline", false, { win = original_state.left_win })
      vim.api.nvim_buf_set_option(left_buf, "bufhidden", "wipe")

      -- Go back to original window
      vim.api.nvim_set_current_win(original_state.original_win)

      -- Create right padding window
      vim.cmd("botright vnew")
      original_state.right_win = vim.api.nvim_get_current_win()

      -- Make it a scratch buffer with no UI elements
      local right_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(original_state.right_win, right_buf)
      vim.api.nvim_set_option_value("number", false, { win = original_state.right_win })
      vim.api.nvim_set_option_value("relativenumber", false, { win = original_state.right_win })
      vim.api.nvim_set_option_value("signcolumn", "no", { win = original_state.right_win })
      vim.api.nvim_set_option_value("foldcolumn", "0", { win = original_state.right_win })
      vim.api.nvim_set_option_value("cursorline", false, { win = original_state.right_win })
      vim.api.nvim_buf_set_option(right_buf, "bufhidden", "wipe")

      -- Go back to center window (original content)
      vim.api.nvim_set_current_win(original_state.original_win)
    end

    -- Set textwidth and line break options for the content window
    vim.opt_local.textwidth = math.floor(80 * 1.30)
    vim.opt_local.linebreak = true  -- Break lines at word boundaries

    M.enabled = true
    vim.notify("Reading mode enabled", vim.log.levels.INFO)
  end
end

return M
