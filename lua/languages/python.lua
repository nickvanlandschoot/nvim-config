-- Python language configuration
-- LSP (Ruff + Pyright), DAP (debugpy), formatting, linting

local M = {}

-- Detect the active Python interpreter
local function detect_python_interpreter()
	-- Check for virtual environment
	local venv = os.getenv("VIRTUAL_ENV")
	if venv then
		local python_path = venv .. "/bin/python"
		if vim.fn.executable(python_path) == 1 then
			return python_path
		end
	end

	-- Check for uv project (look for .venv in current or parent directories)
	local uv_venv = vim.fn.finddir(".venv", ".;")
	if uv_venv ~= "" then
		local python_path = vim.fn.fnamemodify(uv_venv, ":p") .. "bin/python"
		if vim.fn.executable(python_path) == 1 then
			return python_path
		end
	end

	-- Check for uv project using uv's Python path
	if vim.fn.executable("uv") == 1 then
		-- Try to get uv's Python path in the current directory
		local cwd = vim.fn.getcwd()
		local uv_python_path = vim.fn.system("cd " .. vim.fn.shellescape(cwd) .. " && uv python --version 2>&1")
		if vim.v.shell_error == 0 then
			-- uv is available, try to get the actual Python path
			local python_path = vim.fn.system(
				"cd " .. vim.fn.shellescape(cwd) .. ' && uv python -c "import sys; print(sys.executable)" 2>&1'
			)
			if vim.v.shell_error == 0 and python_path ~= "" then
				python_path = vim.fn.trim(python_path)
				if vim.fn.executable(python_path) == 1 then
					return python_path
				end
			end
		end
	end

	-- Check for conda environment
	local conda_env = os.getenv("CONDA_DEFAULT_ENV")
	if conda_env then
		local conda_prefix = os.getenv("CONDA_PREFIX")
		if conda_prefix then
			local python_path = conda_prefix .. "/bin/python"
			if vim.fn.executable(python_path) == 1 then
				return python_path
			end
		end
	end

	-- Try python3 in PATH
	if vim.fn.executable("python3") == 1 then
		return vim.fn.exepath("python3")
	end

	-- Fallback to python
	if vim.fn.executable("python") == 1 then
		return vim.fn.exepath("python")
	end

	return nil -- Let Pyright use its default detection
end

-- Setup Python LSP servers
function M.setup_lsp(capabilities, on_attach)
	-- Ruff LSP configuration (linter/formatter)
	local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
	vim.lsp.config.ruff = {
		cmd = { mason_bin .. "/ruff", "server" },
		filetypes = { "python" },
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			-- Disable hover in favor of Pyright
			client.server_capabilities.hoverProvider = false

			-- Call base on_attach
			on_attach(client, bufnr)

			local bufopts = { noremap = true, silent = true, buffer = bufnr }

			-- Python-specific keymaps for Ruff
			-- Fix all auto-fixable issues with Ruff
			vim.keymap.set("n", "<leader>tf", function()
				vim.lsp.buf.code_action({
					context = {
						only = { "source.fixAll" },
						diagnostics = {},
					},
					apply = true,
				})
			end, vim.tbl_extend("force", bufopts, { desc = "Fix all (Ruff)" }))

			-- Extract to function/method (works in visual mode)
			vim.keymap.set("v", "<leader>te", function()
				vim.lsp.buf.code_action()
			end, vim.tbl_extend("force", bufopts, { desc = "Extract function" }))

			-- Show all refactor options (extract, inline, etc.)
			vim.keymap.set({ "n", "v" }, "<leader>tr", function()
				vim.lsp.buf.code_action()
			end, vim.tbl_extend("force", bufopts, { desc = "Refactor options" }))
		end,
	}

	-- Pyright LSP configuration (type checking)
	-- Detect interpreter on setup, but also update dynamically
	local function get_pyright_settings(bufnr)
		local python_interpreter = detect_python_interpreter()
		local start_dir = vim.fn.getcwd()

		-- If buffer is provided, use its directory as starting point
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			local buf_path = vim.api.nvim_buf_get_name(bufnr)
			if buf_path ~= "" then
				start_dir = vim.fn.fnamemodify(buf_path, ":p:h")
			end
		end

		local workspace_root = start_dir

		-- Try to find project root (look for common markers)
		local root_markers = { ".git", "pyproject.toml", "setup.py", "requirements.txt", "Pipfile", ".venv" }
		for _, marker in ipairs(root_markers) do
			local found = vim.fn.finddir(marker, start_dir .. ";")
			if found ~= "" then
				workspace_root = vim.fn.fnamemodify(found, ":p:h")
				break
			end
			found = vim.fn.findfile(marker, start_dir .. ";")
			if found ~= "" then
				workspace_root = vim.fn.fnamemodify(found, ":p:h")
				break
			end
		end

		return {
			pyright = {
				-- Use Ruff for organizing imports
				disableOrganizeImports = true,
			},
			python = {
				analysis = {
					typeCheckingMode = "standard",
					-- Auto-detect virtual environments
					autoImportCompletions = true,
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "openFilesOnly",
				},
				-- Set the Python interpreter path if detected
				defaultInterpreterPath = python_interpreter,
				-- Help Pyright find venvs automatically (set to workspace root)
				venvPath = workspace_root,
			},
		}
	end

	vim.lsp.config.pyright = {
		cmd = { mason_bin .. "/pyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_markers = {
			".git",
			"pyproject.toml",
			"setup.py",
			"requirements.txt",
			"Pipfile",
			".venv",
			"pyrightconfig.json",
		},
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			-- Update settings when attaching to ensure we use the right interpreter
			local settings = get_pyright_settings(bufnr)
			-- Update client settings
			client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, settings)
			-- Notify Pyright of configuration change
			client.notify("workspace/didChangeConfiguration", { settings = settings })
			on_attach(client, bufnr)

			-- Add diagnostic command to check Pyright settings
			vim.api.nvim_buf_create_user_command(bufnr, "PyrightInfo", function()
				local detected = detect_python_interpreter()
				local settings = get_pyright_settings(bufnr)
				local info = {
					"Pyright Configuration:",
					"  Python Interpreter: " .. (detected or "<not detected>"),
					"  venvPath: " .. (settings.python.venvPath or "<not set>"),
					"  defaultInterpreterPath: " .. (settings.python.defaultInterpreterPath or "<not set>"),
				}
				if detected then
					-- Check if networkx is available
					local check = vim.fn.system(detected .. ' -c "import networkx; print(networkx.__file__)" 2>&1')
					if vim.v.shell_error == 0 then
						table.insert(info, "  networkx found at: " .. vim.fn.trim(check))
					else
						table.insert(info, "  networkx: NOT FOUND in this interpreter")
					end
				end
				vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
			end, { desc = "Show Pyright configuration info" })
		end,
		settings = get_pyright_settings(),
	}

	-- Update Pyright settings when entering Python buffers to catch environment changes
	vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
		pattern = "*.py",
		callback = function(ev)
			local clients = vim.lsp.get_clients({ name = "pyright", bufnr = ev.buf })
			if #clients > 0 then
				local settings = get_pyright_settings(ev.buf)
				for _, client in ipairs(clients) do
					client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, settings)
					client.notify("workspace/didChangeConfiguration", { settings = settings })
				end
			end
		end,
	})
end

-- Setup Python DAP (Debug Adapter Protocol)
function M.setup_dap()
	local dap = require("dap")

	-- Python configurations (using nvim-dap-python)
	require("dap-python").setup("uv")

	-- Fallback configurations if nvim-dap-python doesn't set them
	if not dap.configurations.python then
		dap.configurations.python = {}
	end

	-- Helper function to find Intrace project root
	local function find_intrace_root()
		local current = vim.fn.getcwd()
		-- Look for backend directory or docker-compose.dev.yml
		local markers = { "backend", "docker-compose.dev.yml", ".git" }
		for _, marker in ipairs(markers) do
			local found = vim.fn.finddir(marker, current .. ";") or vim.fn.findfile(marker, current .. ";")
			if found ~= "" then
				local root = vim.fn.fnamemodify(found, ":p:h")
				-- If marker is 'backend', go up one level
				if marker == "backend" then
					root = vim.fn.fnamemodify(root, ":h")
				end
				return root
			end
		end
		-- Fallback to current directory
		return current
	end

	local project_root = find_intrace_root()
	local backend_path = project_root .. "/backend"

	-- Add remote attach configuration for Docker debugpy server
	table.insert(dap.configurations.python, {
		type = "python",
		request = "attach",
		name = "Attach to Backend (Docker)",
		connect = {
			host = "localhost",
			port = 5678,
		},
		pathMappings = {
			{
				localRoot = backend_path,
				remoteRoot = "/app",
			},
		},
		justMyCode = false,
	})

	-- Add configuration for port offset (when using --port flag)
	table.insert(dap.configurations.python, {
		type = "python",
		request = "attach",
		name = "Attach to Backend (Docker) - Port Offset",
		connect = {
			host = "localhost",
			port = 5679,
		},
		pathMappings = {
			{
				localRoot = backend_path,
				remoteRoot = "/app",
			},
		},
		justMyCode = false,
	})
end

-- Setup Python formatting (via conform.nvim)
function M.get_formatters()
	return {
		python = { "ruff_format" },
	}
end

-- Setup Python linting (via nvim-lint)
function M.get_linters()
	return {
		python = { "ruff" },
	}
end

return M
