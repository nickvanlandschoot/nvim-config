return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	config = function()
		require("claudecode").setup({
			diff_opts = {
				vertical_split = false,
			},
		})

		-- Helper functions to preserve cursor position
		local function accept_diff_with_cursor_restore()
			vim.cmd("normal! m'") -- Set mark at current position
			vim.cmd("ClaudeCodeDiffAccept")
			vim.defer_fn(function()
				vim.cmd("normal! ``") -- Return to mark
			end, 100)
		end

		local function deny_diff_with_cursor_restore()
			vim.cmd("normal! m'") -- Set mark at current position
			vim.cmd("ClaudeCodeDiffDeny")
			vim.defer_fn(function()
				vim.cmd("normal! ``") -- Return to mark
			end, 100)
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
	},
}
