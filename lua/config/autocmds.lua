-- Centralized autocmd configuration
-- All autocommands defined in one place

-- ============================================================================
-- LINTING AUTOCMDS
-- ============================================================================

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
	group = lint_augroup,
	callback = function()
		local ok, lint = pcall(require, "lint")
		if ok then
			lint.try_lint()
		end
	end,
	desc = "Trigger linting on buffer enter and insert leave",
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
		local bufname = vim.api.nvim_buf_get_name(0)

		if mark[1] > 0 and mark[1] <= lcount then
			local success = pcall(vim.api.nvim_win_set_cursor, 0, mark)
			if success then
				vim.notify(
					string.format(
						"Restored cursor to line %d, col %d in %s",
						mark[1],
						mark[2],
						vim.fn.fnamemodify(bufname, ":t")
					),
					vim.log.levels.INFO
				)
			end
		else
			vim.notify(
				string.format("No valid cursor position to restore in %s", vim.fn.fnamemodify(bufname, ":t")),
				vim.log.levels.DEBUG
			)
		end
	end,
	desc = "Restore cursor position when opening a file",
})

-- ============================================================================
-- AUTO HOVER / TYPE INFORMATION
-- ============================================================================

-- Toggle state for auto-hover (default: disabled to avoid blocking)
vim.g.auto_hover_enabled = false

-- Show type information automatically on cursor hold
local hover_augroup = vim.api.nvim_create_augroup("auto_hover", { clear = true })

local function setup_auto_hover()
	-- Clear existing autocmds
	vim.api.nvim_clear_autocmds({ group = hover_augroup })

	if vim.g.auto_hover_enabled then
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = hover_augroup,
			callback = function()
				-- Only show in normal/insert mode, skip for special buffers
				local ft = vim.bo.filetype
				if ft == "" or ft == "TelescopePrompt" or ft == "NvimTree" or ft == "neo-tree" or ft == "oil" then
					return
				end

				-- Check if LSP is available for current buffer
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if #clients == 0 then
					return
				end

				-- Show hover information (type/documentation) for symbol under cursor
				-- Use hover.nvim if available (less intrusive), otherwise fallback to default hover
				local ok, hover = pcall(require, "hover")
				if ok then
					hover.hover()
				else
					-- Fallback to default LSP hover
					pcall(function()
						vim.lsp.buf.hover()
					end)
				end
			end,
			desc = "Show type information automatically on cursor hold",
		})
	end
end

-- Initialize auto-hover (disabled by default to avoid blocking)
setup_auto_hover()

-- Export toggle function for keymap
_G.toggle_auto_hover = function()
	vim.g.auto_hover_enabled = not vim.g.auto_hover_enabled
	setup_auto_hover()
	local status = vim.g.auto_hover_enabled and "enabled" or "disabled"
	vim.notify("Auto-hover " .. status, vim.log.levels.INFO)
end

-- Note: Language-specific autocmds (like Python Ruff auto-fix) are defined
-- in their respective language modules (lua/languages/*.lua)
