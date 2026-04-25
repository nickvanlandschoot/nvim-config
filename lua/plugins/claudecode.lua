return {
	"snirt/claudecode.nvim",
	branch = "main",
	dependencies = { "folke/snacks.nvim" },
	config = function()
		require("claudecode").setup({
			diff_opts = {
				vertical_split = false,
				auto_close_on_accept = true,
			},
			terminal = {
				tabs = {
					enabled = true,
					mouse_enabled = true,
					height = 1,
					show_close_button = true,
					show_new_button = true,
					separator = " | ",
					active_indicator = "*",
					keymaps = {
						next_tab = "<C-n>",
						prev_tab = "<C-p>",
						close_tab = false, -- Use <leader>an keymap instead
						new_tab = false, -- Use <leader>al keymap instead
					},
				},
			},
		})

		-- Helper functions to preserve cursor position using event-driven logic
		local function create_cursor_restore_autocmd(mark_pos)
			local augroup = vim.api.nvim_create_augroup("ClaudeCodeCursorRestore", { clear = true })

			-- Create one-shot autocmd that triggers after window/buffer operations settle
			vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
				group = augroup,
				once = true, -- Automatically removes itself after first trigger
				callback = function()
					-- Restore cursor position to the saved mark
					pcall(vim.api.nvim_win_set_cursor, 0, mark_pos)
					-- Clean up the augroup
					vim.api.nvim_del_augroup_by_id(augroup)
				end,
			})
		end

		local function accept_diff_with_cursor_restore()
			local mark_pos = vim.api.nvim_win_get_cursor(0)
			vim.cmd("ClaudeCodeDiffAccept")
			create_cursor_restore_autocmd(mark_pos)
		end

		local function deny_diff_with_cursor_restore()
			local mark_pos = vim.api.nvim_win_get_cursor(0)
			vim.cmd("ClaudeCodeDiffDeny")
			create_cursor_restore_autocmd(mark_pos)
		end

		-- Expose these as commands
		vim.api.nvim_create_user_command("ClaudeCodeDiffAcceptRestore", accept_diff_with_cursor_restore, {})
		vim.api.nvim_create_user_command("ClaudeCodeDiffDenyRestore", deny_diff_with_cursor_restore, {})
	end,
	keys = {
		{ "<leader>a", nil, desc = "AI/Claude Code" },
		{ "<leader>ac", "<cmd>ClaudeCode --dangerously-skip-permissions<cr>", desc = "Toggle Claude" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
		{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
		{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
		{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
		{
			"<leader>as",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			desc = "Add file",
			ft = { "neo-tree", "oil", "minifiles", "netrw" },
		},
		-- Diff management
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAcceptRestore<cr>", desc = "Accept diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDenyRestore<cr>", desc = "Deny diff" },

		-- Multi-session management
		{ "<leader>an", "<cmd>ClaudeCodeNew<cr>", desc = "New Claude session" },
		{ "<leader>al", "<cmd>ClaudeCodeSessions<cr>", desc = "List Claude sessions" },
		{ "<leader>ax", "<cmd>ClaudeCodeCloseSession<cr>", desc = "Close Claude session" },
	},
}
