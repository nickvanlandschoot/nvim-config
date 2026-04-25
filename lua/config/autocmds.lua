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

-- Note: Language-specific autocmds (like Python Ruff auto-fix) are defined
-- in their respective language modules (lua/languages/*.lua)
