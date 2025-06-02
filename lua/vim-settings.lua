-- Set leader key
vim.g.mapleader = " "

-- Line number settings
vim.opt.number = true         -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers

-- Swap file and buffer management settings to prevent E325 errors
vim.opt.swapfile = false        -- Disable swap files entirely
vim.opt.backup = false          -- Disable backup files
vim.opt.writebackup = false     -- Disable backup before overwriting
vim.opt.undofile = true         -- Enable persistent undo instead
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"  -- Set undo directory

-- Create undo directory if it doesn't exist@i
local undo_dir = vim.fn.stdpath("data") .. "/undo"
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, "p")
end

-- Handle swap file conflicts automatically
vim.opt.shortmess:append("A")   -- Don't show swap file messages

vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })

-- Remap 'y' in normal and visual mode to yank to clipboard while preserving default functionality
vim.keymap.set("n", "y", '"+y', { noremap = true })
vim.keymap.set("v", "y", '"+y', { noremap = true })

--Map open diagnostics to shift `f`
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>')

-- LazyGit
vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>', { desc = 'Open LazyGit' })

-- Folding settings (managed by nvim-ufo plugin)
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.opt.foldlevel = 99
-- Remap Tab in visual mode to reselect visual area after indenting

vim.keymap.set("v", "<Tab>", ">gv", { noremap = true })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true })

-- Find current file in NvimTree
vim.keymap.set("n", "<leader>nf", ":NvimTreeFindFile<CR>", { noremap = true, silent = true, desc = 'Find current file in tree' })

-- For normal mode (single line moves)
local function move_line_up(count)
  count = count or vim.v.count1
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local target = row - count
  if target < 1 then target = 1 end
  vim.cmd(string.format("move %d", target - 1))
  vim.api.nvim_win_set_cursor(0, { target, col })
  vim.cmd("normal! ==")
end

local function move_line_down(count)
  count = count or vim.v.count1
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local target = row + count
  vim.cmd(string.format("move %d", target))
  vim.api.nvim_win_set_cursor(0, { target, col })
  vim.cmd("normal! ==")
end

vim.keymap.set("n", "<C-S-k>", function() move_line_up() end, { noremap = true, silent = true, desc = "move line up" })
vim.keymap.set("n", "<C-S-j>", function() move_line_down() end, { noremap = true, silent = true, desc = "move line down" })

-- Visual mode: move selected block up or down by count (default 1)
local function move_visual_selection(direction)
  local count = vim.v.count1  -- count prefix (defaults to 1)
  local start_line = vim.fn.line("'<")
  local end_line   = vim.fn.line("'>")
  if direction == "up" then
    -- For up, move the block to after the line: (start_line - (count + 1))
    local target = start_line - (count + 1)
    if target < 0 then target = 0 end
    vim.cmd(string.format("'<,'>move %d", target))
  elseif direction == "down" then
    -- For down, move the block to after: end_line + count
    local target = end_line + count
    vim.cmd(string.format("'<,'>move %d", target))
  end
  -- Reselect the moved block and reindent
  vim.cmd("normal! gv=gv")
end

vim.keymap.set("v", "<C-S-k>", function() move_visual_selection("up") end,
  { noremap = true, silent = true, desc = "move visual selection up" })
vim.keymap.set("v", "<C-S-j>", function() move_visual_selection("down") end,
  { noremap = true, silent = true, desc = "move visual selection down" })

-- Set scrolloff 
vim.opt.scrolloff = 12

-- Prevent neovide animations
vim.g.neovide_position_animation_length = 0
vim.g.neovide_cursor_animation_length = 0.00
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_cursor_animate_in_insert_mode = false
vim.g.neovide_cursor_animate_command_line = false
vim.g.neovide_scroll_animation_far_lines = 0
vim.g.neovide_scroll_animation_length = 0.00

-- spell check options
--vim.opt.spell = true
vim.opt.spelllang = "en_us"
