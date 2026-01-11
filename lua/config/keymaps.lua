-- Centralized keymap configuration
-- All keybindings defined in one place for easy reference and conflict detection

local opts = { noremap = true, silent = true }

-- ============================================================================
-- CORE VIM KEYMAPS
-- ============================================================================

-- Clipboard operations
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { noremap = true, desc = "Yank to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { noremap = true, desc = "Paste from clipboard" })

-- Visual mode indentation (maintain selection)
vim.keymap.set("v", "<Tab>", ">gv", { noremap = true, desc = "Indent and reselect" })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, desc = "Unindent and reselect" })

-- Window/split management (Neovim windows)
vim.keymap.set("n", "<C-s>", "<cmd>split<cr>", { noremap = true, desc = "Horizontal split" })
vim.keymap.set("n", "<C-p>", "<cmd>vsplit<cr>", { noremap = true, desc = "Vertical split" })
vim.keymap.set("n", "<C-q>", "<cmd>close<cr>", { noremap = true, desc = "Close window" })

-- Tmux pane management
local function tmux_split(direction)
	local cmd = direction == "h" and "tmux split-window -h" or "tmux split-window -v"
	local result = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		vim.notify("Failed to create tmux pane. Are you in a tmux session?", vim.log.levels.WARN)
	end
end

vim.keymap.set("n", "<leader>tp", function()
	tmux_split("h")
end, vim.tbl_extend("force", opts, { desc = "Tmux: Vertical pane" }))
vim.keymap.set("n", "<leader>ts", function()
	tmux_split("v")
end, vim.tbl_extend("force", opts, { desc = "Tmux: Horizontal pane" }))
vim.keymap.set("n", "<leader>tx", function()
	local result = vim.fn.system("tmux kill-pane")
	if vim.v.shell_error ~= 0 then
		vim.notify("Failed to close tmux pane.", vim.log.levels.WARN)
	end
end, vim.tbl_extend("force", opts, { desc = "Tmux: Close pane" }))

-- ============================================================================
-- LSP KEYMAPS
-- ============================================================================

-- Safe LSP operation wrapper (defined in lsp-config.lua, used here)
local function safe_lsp_operation(operation)
	return function()
		local ok, err = pcall(operation)
		if not ok then
			vim.notify("LSP operation failed: " .. tostring(err), vim.log.levels.WARN)
		end
	end
end

-- Navigation (using Telescope with vertical layout - results at bottom, preview on top)
local telescope_vertical = {
	layout_strategy = "vertical",
	layout_config = {
		width = 0.95,
		height = 0.95,
		preview_height = 0.6,
		mirror = false, -- results at bottom, preview on top
	},
}

vim.keymap.set("n", "gd", function()
	-- Ensure we have a valid buffer and window
	local current_buf = vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(current_buf) then
		vim.notify("Invalid buffer", vim.log.levels.WARN)
		return
	end

	local ok, err = pcall(function()
		require("telescope.builtin").lsp_definitions(vim.tbl_extend("force", telescope_vertical, {
			bufnr = current_buf,
		}))
	end)
	if not ok then
		vim.notify("Error opening definitions: " .. tostring(err), vim.log.levels.WARN)
		-- Fallback to default LSP goto definition
		safe_lsp_operation(vim.lsp.buf.definition)()
	end
end, vim.tbl_extend("force", opts, { desc = "Go to definition (Telescope)" }))
vim.keymap.set("n", "gr", function()
	-- Ensure we have a valid buffer and window
	local current_buf = vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(current_buf) then
		vim.notify("Invalid buffer", vim.log.levels.WARN)
		return
	end

	local ok, err = pcall(function()
		require("telescope.builtin").lsp_references(vim.tbl_extend("force", telescope_vertical, {
			bufnr = current_buf,
		}))
	end)
	if not ok then
		vim.notify("Error opening references: " .. tostring(err), vim.log.levels.WARN)
		-- Fallback to default LSP references
		safe_lsp_operation(vim.lsp.buf.references)()
	end
end, vim.tbl_extend("force", opts, { desc = "Go to references (Telescope)" }))
-- Note: gi was mapped to hover, but K is the standard key for hover
-- Removed gi mapping to avoid confusion - use K instead
vim.keymap.set(
	"n",
	"gk",
	function()
		-- Toggle auto-hover on/off
		if _G.toggle_auto_hover then
			_G.toggle_auto_hover()
		else
			-- Fallback: show type information manually
			safe_lsp_operation(function()
				vim.lsp.buf.signature_help()
			end)()
		end
	end,
	vim.tbl_extend("force", opts, { desc = "Toggle auto-hover" })
)
vim.keymap.set("n", "<leader>gi", function()
	require("telescope.builtin").lsp_implementations(telescope_vertical)
end, vim.tbl_extend("force", opts, { desc = "Go to implementation (Telescope)" }))
vim.keymap.set(
	"n",
	"K",
	function()
		-- Use hover.nvim if available (better UI), otherwise fallback to default
		local ok, hover = pcall(require, "hover")
		if ok then
			hover.hover()
		else
			safe_lsp_operation(vim.lsp.buf.hover)()
		end
	end,
	vim.tbl_extend("force", opts, { desc = "Hover documentation" })
)

-- Actions
vim.keymap.set(
	{ "n", "v" },
	"<leader>rn",
	safe_lsp_operation(function()
		vim.lsp.buf.rename()
	end),
	vim.tbl_extend("force", opts, { desc = "Rename symbol" })
)
vim.keymap.set(
	{ "n", "v" },
	"<leader>ca",
	safe_lsp_operation(function()
		vim.lsp.buf.code_action()
	end),
	vim.tbl_extend("force", opts, { desc = "Code action" })
)

-- Diagnostics
vim.keymap.set(
	"n",
	"<leader>d",
	vim.diagnostic.open_float,
	vim.tbl_extend("force", opts, { desc = "Show diagnostics" })
)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
vim.keymap.set(
	"n",
	"<leader>dl",
	vim.diagnostic.setloclist,
	vim.tbl_extend("force", opts, { desc = "Diagnostics to loclist" })
)
vim.keymap.set("n", "<leader>dg", function()
	require("utils.diagnostics").copy_all_diagnostics()
end, vim.tbl_extend("force", opts, { desc = "Copy all diagnostics" }))

-- ============================================================================
-- TELESCOPE KEYMAPS
-- ============================================================================

vim.keymap.set(
	"n",
	"<leader>ff",
	"<cmd>Telescope find_files<cr>",
	vim.tbl_extend("force", opts, { desc = "Find files" })
)
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", vim.tbl_extend("force", opts, { desc = "Live grep" }))
vim.keymap.set("n", "<leader>fr", function()
	require("telescope.builtin").grep_string()
end, vim.tbl_extend("force", opts, { desc = "Global find and replace" }))
vim.keymap.set("n", "<leader>fh", function()
	local harpoon = require("harpoon")
	local conf = require("telescope.config").values
	local function toggle_telescope(harpoon_files)
		local file_paths = {}
		for _, item in ipairs(harpoon_files.items) do
			table.insert(file_paths, item.value)
		end
		require("telescope.pickers")
			.new({}, {
				prompt_title = "Harpoon",
				finder = require("telescope.finders").new_table({ results = file_paths }),
				previewer = conf.file_previewer({}),
				sorter = conf.generic_sorter({}),
			})
			:find()
	end
	toggle_telescope(harpoon:list())
end, vim.tbl_extend("force", opts, { desc = "Harpoon in Telescope" }))

vim.keymap.set("n", "<leader>fe", function()
	require("telescope.builtin").diagnostics({ bufnr = 0, severity = "ERROR" })
end, vim.tbl_extend("force", opts, { desc = "Buffer errors" }))

vim.keymap.set("n", "<leader>fd", function()
	require("telescope.builtin").diagnostics({ bufnr = 0 })
end, vim.tbl_extend("force", opts, { desc = "Buffer diagnostics" }))

vim.keymap.set(
	"n",
	"<leader><leader>",
	"<cmd>Telescope oldfiles<cr>",
	vim.tbl_extend("force", opts, { desc = "Recent files" })
)
vim.keymap.set(
	"n",
	"<leader>f",
	"<cmd>Telescope current_buffer_fuzzy_find<cr>",
	vim.tbl_extend("force", opts, { desc = "Fuzzy find in buffer" })
)
vim.keymap.set(
	"n",
	"<leader>fb",
	"<cmd>Telescope buffers<cr>",
	vim.tbl_extend("force", opts, { desc = "Find buffers" })
)

-- Numbered buffer switching (e.g., <leader>b2, <leader>b3)
vim.keymap.set(
	"n",
	"<leader>gs",
	"<cmd>Telescope git_status<cr>",
	vim.tbl_extend("force", opts, { desc = "Git status" })
)
vim.keymap.set(
	"n",
	"<leader>gd",
	"<cmd>TelescopeGitDiff<cr>",
	vim.tbl_extend("force", opts, { desc = "Git diff (changed files)" })
)

vim.keymap.set("n", "<leader>fs", function()
	require("telescope.builtin").lsp_document_symbols({ symbols = { "function", "method", "class" } })
end, vim.tbl_extend("force", opts, { desc = "Document symbols (filtered)" }))

vim.keymap.set(
	"n",
	"<leader>f.",
	"<cmd>Telescope lsp_document_symbols<cr>",
	vim.tbl_extend("force", opts, { desc = "Document symbols (all)" })
)

vim.keymap.set("n", "<leader>fo", function()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Find Directories",
			finder = finders.new_oneshot_job({
				"fd",
				"--type",
				"d",
				"--hidden",
				"--exclude",
				".git",
				"--exclude",
				"node_modules",
				"--exclude",
				".venv",
				"--exclude",
				"venv",
				"--exclude",
				"__pycache__",
				"--exclude",
				"dist",
				"--exclude",
				"build",
				"--exclude",
				"target",
			}, nil),
			sorter = conf.file_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection then
						require("oil").open(selection[1])
					end
				end)
				return true
			end,
		})
		:find()
end, vim.tbl_extend("force", opts, { desc = "Find directories (Oil)" }))

-- Tmux session switcher
vim.keymap.set("n", "<leader>s", function()
	local handle = io.popen("tmux list-sessions -F '#S'")
	local sessions = {}
	if handle then
		for session in handle:lines() do
			table.insert(sessions, session)
		end
		handle:close()
	end
	if #sessions == 0 then
		print("No tmux sessions found")
		return
	end
	require("telescope.pickers")
		.new({}, {
			prompt_title = "Switch Tmux Session",
			finder = require("telescope.finders").new_table({ results = sessions }),
			sorter = require("telescope.config").values.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection then
						vim.fn.system("tmux switch-client -t " .. selection[1])
					end
				end)
				return true
			end,
		})
		:find()
end, vim.tbl_extend("force", opts, { desc = "Switch tmux session" }))

-- ============================================================================
-- FORMATTING KEYMAPS
-- ============================================================================

-- Format with conform.nvim (was <leader>f, now <leader>fm to avoid conflict)
vim.keymap.set("", "<leader>fm", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

-- ============================================================================
-- LINTING KEYMAPS
-- ============================================================================

vim.keymap.set("n", "<leader>ll", function()
	require("lint").try_lint()
end, vim.tbl_extend("force", opts, { desc = "Trigger linting" }))

-- ============================================================================
-- TYPESCRIPT-SPECIFIC KEYMAPS
-- ============================================================================

vim.keymap.set(
	"n",
	"<leader>to",
	"<cmd>TSToolsOrganizeImports<cr>",
	vim.tbl_extend("force", opts, { desc = "Organize imports (TS)" })
)
vim.keymap.set(
	"n",
	"<leader>ts",
	"<cmd>TSToolsSortImports<cr>",
	vim.tbl_extend("force", opts, { desc = "Sort imports (TS)" })
)
vim.keymap.set(
	"n",
	"<leader>tru",
	"<cmd>TSToolsRemoveUnused<cr>",
	vim.tbl_extend("force", opts, { desc = "Remove unused (TS)" })
)
vim.keymap.set(
	"n",
	"<leader>trf",
	"<cmd>TSToolsRemoveUnusedImports<cr>",
	vim.tbl_extend("force", opts, { desc = "Remove unused imports (TS)" })
)
vim.keymap.set("n", "<leader>tfa", "<cmd>TSToolsFixAll<cr>", vim.tbl_extend("force", opts, { desc = "Fix all (TS)" }))
vim.keymap.set(
	"n",
	"<leader>tai",
	"<cmd>TSToolsAddMissingImports<cr>",
	vim.tbl_extend("force", opts, { desc = "Add missing imports (TS)" })
)
vim.keymap.set(
	"n",
	"<leader>tgd",
	"<cmd>TSToolsGoToSourceDefinition<cr>",
	vim.tbl_extend("force", opts, { desc = "Go to source definition (TS)" })
)
vim.keymap.set(
	"n",
	"<leader>tfu",
	"<cmd>TSToolsFileReferences<cr>",
	vim.tbl_extend("force", opts, { desc = "File references (TS)" })
)
vim.keymap.set(
	"n",
	"<leader>trn",
	"<cmd>TSToolsRenameFile<cr>",
	vim.tbl_extend("force", opts, { desc = "Rename file (TS)" })
)

-- ============================================================================
-- PYTHON-SPECIFIC KEYMAPS (Ruff)
-- ============================================================================

-- Note: These are set up in languages/python.lua as buffer-local keymaps
-- Listed here for reference:
-- <leader>tf - Fix all auto-fixable issues (Ruff)
-- <leader>te - Extract to function/method (visual mode)
-- <leader>tr - Show all refactor options

-- ============================================================================
-- DEBUG (DAP) KEYMAPS
-- ============================================================================

vim.keymap.set("n", "<space>b", function()
	require("dap").toggle_breakpoint()
end, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
vim.keymap.set("n", "<space>gb", function()
	require("dap").run_to_cursor()
end, vim.tbl_extend("force", opts, { desc = "Run to cursor" }))
vim.keymap.set("n", "<space>dl", function()
	require("dap").run_last()
end, vim.tbl_extend("force", opts, { desc = "Debug: Run last" }))
vim.keymap.set("n", "<space>dc", function()
	require("dap").continue()
end, vim.tbl_extend("force", opts, { desc = "Debug: Continue/Start" }))
vim.keymap.set("n", "<space>ds", function()
	local dap = require("dap")
	local filetype = vim.bo.filetype
	local configs = dap.configurations[filetype]
	if not configs or #configs == 0 then
		vim.notify("No debug configurations found for filetype: " .. filetype, vim.log.levels.WARN)
		return
	end
	if #configs == 1 then
		dap.run(configs[1])
	else
		vim.ui.select(configs, {
			prompt = "Select debug configuration:",
			format_item = function(config)
				return config.name or "Unknown"
			end,
		}, function(choice)
			if choice then
				dap.run(choice)
			end
		end)
	end
end, vim.tbl_extend("force", opts, { desc = "Debug: Select config" }))

vim.keymap.set("n", "<space>?", function()
	require("dapui").eval(nil, { enter = true })
end, vim.tbl_extend("force", opts, { desc = "Evaluate expression" }))

-- Function keys for debugging
vim.keymap.set("n", "<F1>", function()
	require("dap").continue()
end, vim.tbl_extend("force", opts, { desc = "Debug: Continue" }))
vim.keymap.set("n", "<F2>", function()
	require("dap").step_into()
end, vim.tbl_extend("force", opts, { desc = "Debug: Step into" }))
vim.keymap.set("n", "<F3>", function()
	require("dap").step_over()
end, vim.tbl_extend("force", opts, { desc = "Debug: Step over" }))
vim.keymap.set("n", "<F4>", function()
	require("dap").step_out()
end, vim.tbl_extend("force", opts, { desc = "Debug: Step out" }))
vim.keymap.set("n", "<F5>", function()
	require("dap").step_back()
end, vim.tbl_extend("force", opts, { desc = "Debug: Step back" }))
vim.keymap.set("n", "<F6>", function()
	require("dap").toggle_breakpoint()
end, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
vim.keymap.set("n", "<F13>", function()
	require("dap").restart()
end, vim.tbl_extend("force", opts, { desc = "Debug: Restart" }))

-- ============================================================================
-- FILE EXPLORER KEYMAPS
-- ============================================================================

vim.keymap.set("n", "-", "<CMD>Oil<CR>", vim.tbl_extend("force", opts, { desc = "Open Oil" }))

-- ============================================================================
-- GIT KEYMAPS
-- ============================================================================

-- ============================================================================
-- UI / NOTIFICATION KEYMAPS
-- ============================================================================

vim.keymap.set("n", "<leader>n", function()
	Snacks.notifier.show_history()
end, vim.tbl_extend("force", opts, { desc = "Notification history" }))
vim.keymap.set("n", "<leader>nd", function()
	Snacks.notifier.hide()
end, vim.tbl_extend("force", opts, { desc = "Dismiss notifications" }))

-- ============================================================================
-- AI ASSISTANT KEYMAPS
-- ============================================================================

-- Claude Code keymaps are defined in lua/plugins/claudecode.lua
-- Main keymaps:
--   <leader>ac - Toggle Claude
--   <leader>af - Focus Claude
--   <leader>ar - Resume Claude
--   <leader>aC - Continue Claude
--   <leader>am - Select Claude model
--   <leader>ab - Add current buffer
--   <leader>as - Send to Claude (visual mode) or add file (file explorer)
--   <leader>aa - Accept diff
--   <leader>ad - Deny diff

-- NeoCodeium (AI completion powered by Windsurf)
-- Keymaps are defined in lua/plugins/neocodeium.lua
-- Main keymaps:
--   <A-f> - Accept completion
--   <A-w> - Accept word
--   <A-a> - Accept line
--   <A-e> - Cycle/complete suggestions
--   <A-r> - Cycle suggestions (reverse)
--   <A-c> - Clear suggestions
--   <leader>ta - Toggle NeoCodeium

-- ============================================================================
-- FOLDING KEYMAPS (UFO)
-- ============================================================================

-- Note: zR and zM are mapped in lua/plugins/ufo.lua
-- These are kept here for reference but the plugin mappings take precedence
