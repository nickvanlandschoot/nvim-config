return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"ThePrimeagen/harpoon",
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("telescope").setup({
				defaults = {
					-- Custom preview title with just filename and icon
					dynamic_preview_title = true,
					preview_title = function(_, entry)
						if entry and entry.filename then
							local filename = vim.fn.fnamemodify(entry.filename, ":t")
							local icon, icon_hl =
								require("nvim-web-devicons").get_icon(filename, nil, { default = true })
							if icon then
								return icon .. " " .. filename
							end
							return filename
						end
						return "Preview"
					end,
					hidden = true,
					file_ignore_patterns = {
						"node_modules/",
						".git/",
						".venv/",
						"venv/",
						"__pycache__/",
						"%.pyc",
						"%.pyo",
						"%.pyd",
						"%.so",
						"%.dll",
						"%.dylib",
						"%.zip",
						"%.tar",
						"%.gz",
						"%.bz2",
						"%.xz",
						"%.cache",
						"%.DS_Store",
						"%.class",
						"%.o",
						"%.a",
						"%.out",
						"%.pdf",
						"%.jpg",
						"%.jpeg",
						"%.png",
						"%.gif",
						"%.svg",
						"%.ico",
						"%.db",
						"%.sqlite",
						"%.sqlite3",
						"%.min.js",
						"%.min.css",
						"dist/",
						"build/",
						"target/",
						"vendor/",
						"%.log",
						"%.tmp",
						"%.temp",
						"%.swp",
						"%.swo",
					},
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
						"--glob=!.git/",
						"--glob=!node_modules/",
						"--glob=!.venv/",
						"--glob=!venv/",
						"--glob=!__pycache__/",
						"--glob=!dist/",
						"--glob=!build/",
						"--glob=!target/",
						"--glob=!vendor/",
					},
				},
				extensions = {
					["ui-select"] = require("telescope.themes").get_dropdown({}),
				},
			})

			require("telescope").load_extension("ui-select")

			-- Resolve Git pickers from the current file when possible, and fail with a
			-- normal notification instead of letting Telescope throw outside a repo.
			local function current_git_root()
				local path = vim.api.nvim_buf_get_name(0)
				local start_dir = path ~= "" and vim.fs.dirname(path) or vim.fn.getcwd()
				if not start_dir or vim.fn.isdirectory(start_dir) == 0 then
					start_dir = vim.fn.getcwd()
				end

				local result = vim.system(
					{ "git", "-C", start_dir, "rev-parse", "--show-toplevel" },
					{ text = true }
				):wait()
				if result.code ~= 0 then
					return nil
				end
				return vim.trim(result.stdout or "")
			end

			local function git_status_picker()
				local root = current_git_root()
				if not root or root == "" then
					vim.notify("Not inside a Git repository", vim.log.levels.WARN)
					return
				end

				local ok, err = pcall(require("telescope.builtin").git_status, { cwd = root })
				if not ok then
					vim.notify("Could not open Git status: " .. tostring(err), vim.log.levels.ERROR)
				end
			end

			vim.api.nvim_create_user_command("TelescopeGitStatus", git_status_picker, {})
			vim.api.nvim_create_user_command("TelescopeGitDiff", git_status_picker, {})

			-- Enhanced find_files that always includes force-included files even if in .gitignore
			-- Uses Telescope's built-in find_files which already has streaming support
			local function find_files_plus(opts)
				opts = opts or {}
				
				-- Check if fd is available, otherwise fall back to default
				local fd_available = vim.fn.executable("fd") == 1
				
				local find_opts = {
					-- Ensure hidden files are shown
					hidden = true,
					-- Limit results to prevent memory issues
					limit = 1000,
				}
				
				-- Use fd if available (faster and streams properly). The normal command
				-- respects Git ignores; run a second fd command for the explicitly
				-- force-included patterns so those files are added without exposing all
				-- ignored files.
				if fd_available then
					local force_patterns = require("config.force-include-files")
					local fd_args = {
						"--type", "f", "--hidden",
						"--exclude", ".git",
						"--exclude", "node_modules",
						"--exclude", ".venv",
						"--exclude", "venv",
						"--exclude", "__pycache__",
					}
					local command_parts = { "fd" }
					for _, arg in ipairs(fd_args) do
						table.insert(command_parts, vim.fn.shellescape(arg))
					end
					local force_commands = {}
					for _, pattern in ipairs(force_patterns) do
						-- fd's --glob matches basenames, so make the relative directory
						-- the search root (e.g. intraceadx/* -> fd ... intraceadx).
						local directory, basename = pattern:match("^(.*)/([^/]*)$")
						directory = directory or "."
						basename = basename or pattern
						table.insert(
							force_commands,
							table.concat(command_parts, " ")
								.. " --no-ignore-vcs --glob "
								.. vim.fn.shellescape(basename)
								.. " "
								.. vim.fn.shellescape(directory)
						)
					end
					find_opts.find_command = {
						"sh", "-c",
						"(" .. table.concat(command_parts, " ") .. "; "
							.. table.concat(force_commands, "; ") .. ") | sort -u",
					}
				end

				-- Use Telescope's built-in find_files which handles streaming efficiently
				-- It properly formats entries so they don't appear greyed out
				require("telescope.builtin").find_files(vim.tbl_extend("keep", find_opts, opts))
			end

			-- Make it available as a command
			vim.api.nvim_create_user_command("TelescopeFindFilesPlus", find_files_plus, {})
		end,
	},
}
