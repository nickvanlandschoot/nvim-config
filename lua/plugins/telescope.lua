return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ThePrimeagen/harpoon",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      require("telescope").setup({
        defaults = {
          hidden = false,
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
      local builtin = require("telescope.builtin")
      
      -- Global find and replace function using ripgrep
      local function global_find_replace()
        local search_term = vim.fn.input("Search for: ")
        if search_term == "" then
          return
        end
        
        local replace_term = vim.fn.input("Replace with: ")
        
        -- Use telescope to show all matches
        builtin.grep_string({
          search = search_term,
          use_regex = true,
          attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            
            -- Custom action to perform find and replace
            local function perform_replace()
              local picker = action_state.get_current_picker(prompt_bufnr)
              local entries = picker:get_multi_selection()
              
              -- If no multi-selection, use current selection
              if vim.tbl_isempty(entries) then
                entries = { action_state.get_selected_entry() }
              end
              
              actions.close(prompt_bufnr)
              
              -- Group entries by filename
              local files = {}
              for _, entry in ipairs(entries) do
                local filename = entry.filename
                if not files[filename] then
                  files[filename] = {}
                end
                table.insert(files[filename], {
                  lnum = entry.lnum,
                  col = entry.col,
                  text = entry.text
                })
              end
              
              -- Perform replacements
              local total_replacements = 0
              for filename, file_entries in pairs(files) do
                vim.cmd("edit " .. filename)
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                local modified = false
                
                -- Sort entries by line number (descending) to avoid line number shifts
                table.sort(file_entries, function(a, b) return a.lnum > b.lnum end)
                
                for _, entry in ipairs(file_entries) do
                  local line_idx = entry.lnum - 1
                  if line_idx < #lines then
                    local line = lines[line_idx + 1]
                    local new_line = line:gsub(search_term, replace_term)
                    if new_line ~= line then
                      lines[line_idx + 1] = new_line
                      modified = true
                      total_replacements = total_replacements + 1
                    end
                  end
                end
                
                if modified then
                  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
                  vim.cmd("write")
                end
              end
              
              print(string.format("Replaced %d occurrences across %d files", total_replacements, vim.tbl_count(files)))
            end
            
            -- Map Enter to perform replace
            map("i", "<CR>", perform_replace)
            map("n", "<CR>", perform_replace)
            
            -- Map Tab to select multiple entries
            map("i", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
            map("n", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
            
            return true
          end,
        })
      end

      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fr", global_find_replace, { desc = "🔄 Global find and replace" })
      vim.keymap.set("n", "<leader>fh", function()
        local harpoon = require("harpoon")
        local conf = require("telescope.config").values
        local function toggle_telescope(harpoon_files)
          local file_paths = {}
          for _, item in ipairs(harpoon_files.items) do
            table.insert(file_paths, item.value)
          end

          require("telescope.pickers").new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({
              results = file_paths,
            }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
          }):find()
        end

        toggle_telescope(harpoon:list())
      end, { desc = "Open Harpoon in Telescope" })

            vim.keymap.set("n", "<leader>fe", function()
        builtin.diagnostics({ bufnr = 0, severity = "ERROR" }) -- Only show errors in the current buffer
      end, {})

                  vim.keymap.set("n", "<leader>fd", function()
        builtin.diagnostics({ bufnr = 0, severity = "DIAGNOSTIC" }) -- Only show errors in the current buffer
      end, {})



      vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, {})
      vim.keymap.set("n", "<leader>f", builtin.current_buffer_fuzzy_find, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})

      -- Git status picker - shows changed files in floating window
      vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "📋 Git status (changed files)" })

      vim.keymap.set("n", "<leader>fs", function()
        require("telescope.builtin").lsp_document_symbols({
          symbols = { "function", "method" }
        })
      end)

      vim.keymap.set("n", "<leader>f.", builtin.lsp_document_symbols)
      vim.keymap.set("n", "<leader>bm", function()
        require("telescope").extensions.bookmarks.list()
      end, { desc = "🔖 Find bookmarks" })

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

        require("telescope.pickers").new({}, {
          prompt_title = "Switch Tmux Session",
          finder = require("telescope.finders").new_table({
            results = sessions,
          }),
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
        }):find()
      end, { desc = "Switch tmux session" })

      require("telescope").load_extension("ui-select")
    end,
  },
}

