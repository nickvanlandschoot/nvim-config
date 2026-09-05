-- Centralized autocmd configuration
-- All autocommands defined in one place

-- ============================================================================
-- LINTING AUTOCMDS
-- ============================================================================

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	group = lint_augroup,
	callback = function()
		local ok, lint = pcall(require, "lint")
		if ok then
			lint.try_lint()
		end
	end,
	desc = "Trigger linting on save",
})

-- ============================================================================
-- TERMINAL AUTOCMDS
-- ============================================================================

-- Set up tmux navigation for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.keymap.set("t", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { buffer = true })
		vim.keymap.set("t", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { buffer = true })
		vim.keymap.set("t", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { buffer = true })
		vim.keymap.set("t", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { buffer = true })
	end,
	desc = "Set up tmux navigation in terminal mode",
})

-- ============================================================================
-- OTHER AUTOCMDS
-- ============================================================================

-- Restore cursor position when opening a file
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)

		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
	desc = "Restore cursor position when opening a file",
})

local function is_editing_window(bufnr, winid)
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(winid) then
		return false
	end
	if vim.api.nvim_win_get_buf(winid) ~= bufnr or vim.bo[bufnr].buftype ~= "" then
		return false
	end

	-- Floats can use a normal buffer while still being transient UI. Never apply
	-- file-window layout options to them.
	local config = vim.api.nvim_win_get_config(winid)
	return not config.relative or config.relative == ""
end

-- ============================================================================
-- LINE NUMBER AUTOCMDS
-- ============================================================================

-- `number` and `relativenumber` are window-local. Restore them only in real
-- editing windows; a floating window may still use a normal buffer.
local line_number_augroup = vim.api.nvim_create_augroup("relative_line_numbers", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
	group = line_number_augroup,
	callback = function(args)
		local winid = vim.api.nvim_get_current_win()
		if is_editing_window(args.buf, winid) then
			vim.wo[winid].number = true
			vim.wo[winid].relativenumber = true
		end
	end,
	desc = "Keep relative line numbers enabled in file windows",
})

-- ============================================================================
-- WRAPPING AUTOCMDS
-- ============================================================================

local wrapping_augroup = vim.api.nvim_create_augroup("wrapping", { clear = true })

local function configure_window_layout(args)
	local winid = vim.api.nvim_get_current_win()
	if not is_editing_window(args.buf, winid) then
		return
	end

	vim.wo[winid].wrap = true
	vim.wo[winid].linebreak = vim.bo[args.buf].filetype == "markdown" or vim.bo[args.buf].filetype == "mdx"
	vim.wo[winid].breakindent = true
	vim.wo[winid].showbreak = "↪ "
end

-- Apply wrapping only to real editing windows. A catch-all FileType autocmd
-- also runs for prompt and picker buffers and can make their cursor appear at
-- the wrong column.
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "FileType" }, {
	group = wrapping_augroup,
	callback = configure_window_layout,
	desc = "Configure wrapping in normal editing windows",
})

-- Prompt buffers must remain a single, unscrolled display line. This covers
-- Telescope and other prompt UIs; Snacks also receives the same options in its
-- plugin config because it creates input windows with noautocmd.
local prompt_layout_augroup = vim.api.nvim_create_augroup("prompt_window_layout", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "FileType" }, {
	group = prompt_layout_augroup,
	callback = function(args)
		local winid = vim.api.nvim_get_current_win()
		if vim.api.nvim_win_is_valid(winid)
			and vim.api.nvim_win_get_buf(winid) == args.buf
			and vim.bo[args.buf].buftype == "prompt"
		then
			vim.wo[winid].number = false
			vim.wo[winid].relativenumber = false
			vim.wo[winid].wrap = false
			vim.wo[winid].linebreak = false
			vim.wo[winid].breakindent = false
			vim.wo[winid].showbreak = ""
			vim.wo[winid].scrolloff = 0
			vim.wo[winid].sidescrolloff = 0
		end
	end,
	desc = "Keep prompt windows aligned and editable",
})


-- ============================================================================
-- SHADA FILE CLEANUP
-- ============================================================================

-- Clean up leftover ShaDa temp files on exit to prevent E138 errors
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		local shada_dir = vim.fn.stdpath("state") .. "/shada"
		local temp_pattern = shada_dir .. "/main.shada.tmp.*"
		
		-- Clean up any leftover temp files
		vim.fn.system("rm -f " .. vim.fn.shellescape(temp_pattern))
	end,
	desc = "Clean up ShaDa temp files on exit",
})

-- Also clean up on startup if there are too many temp files (safety check)
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		local shada_dir = vim.fn.stdpath("state") .. "/shada"
		local temp_pattern = shada_dir .. "/main.shada.tmp.*"
		
		-- Count temp files
		local temp_files = vim.fn.glob(temp_pattern, false, true)
		if #temp_files > 5 then
			-- Too many temp files, clean them up
			vim.fn.system("rm -f " .. vim.fn.shellescape(temp_pattern))
			vim.notify("Cleaned up " .. #temp_files .. " leftover ShaDa temp files", vim.log.levels.INFO)
		end
	end,
	desc = "Clean up excessive ShaDa temp files on startup",
})

-- ============================================================================
-- NVIM SERVER REGISTRATION
-- ============================================================================

-- Register this instance's server socket so external scripts (e.g. theme
-- switcher) can find and talk to it via --server.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local server = vim.v.servername
    if server == "" then return end
    local dir = vim.fn.expand("~/.cache/nvim/servers")
    vim.fn.mkdir(dir, "p")
    local path = dir .. "/" .. vim.fn.getpid()
    vim.fn.writefile({ server }, path)
  end,
  desc = "Register nvim server socket for theme switcher",
})

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    vim.fn.delete(vim.fn.expand("~/.cache/nvim/servers") .. "/" .. vim.fn.getpid())
  end,
  desc = "Unregister nvim server socket on exit",
})

-- `scrolloff` provides safe viewport padding. Do not emulate extra EOF space
-- with `normal! <C-E>` from CursorMovedI/TextChangedI: those events also fire
-- inside one-line prompt buffers, where scrolling can hide the editable line
-- or desynchronise the visible cursor from the text.

-- Note: Language-specific autocmds (like Python Ruff auto-fix) are defined
-- in their respective language modules (lua/languages/*.lua)
