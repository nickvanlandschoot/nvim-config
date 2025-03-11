return {
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "ThePrimeagen/harpoon",
    },
    config = function()
      require("telescope").setup({
        defaults = {
          hidden = false,
        },
        extensions = {
          ["ui-select"] = require("telescope.themes").get_dropdown({}),
        },
      })
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
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
      vim.keymap.set("n", "<leader>fd", function()
        builtin.diagnostics({ bufnr = 0 }) -- Only show diagnostics for the current buffer
      end, {})
      vim.keymap.set("n", "<leader>fe", function()
        builtin.diagnostics({ bufnr = 0, severity = "ERROR" }) -- Only show errors in the current buffer
      end, {})
      vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, {})
      vim.keymap.set("n", "<leader>f", builtin.current_buffer_fuzzy_find, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
      vim.keymap.set("n", "<leader>f.", builtin.lsp_document_symbols, {})
      require("telescope").load_extension("ui-select")
    end,
  },
}

