return {
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- Store the current buffer before opening lazygit
      local function store_current_buffer()
        vim.g.lazygit_previous_buffer = vim.api.nvim_get_current_buf()
      end

      -- Return to the previous buffer after lazygit closes
      local function return_to_previous_buffer()
        if vim.g.lazygit_previous_buffer then
          vim.api.nvim_set_current_buf(vim.g.lazygit_previous_buffer)
          vim.g.lazygit_previous_buffer = nil
        end
      end

      vim.g.lazygit_config = {
        -- Command to execute when lazygit is opened
        cmd = "lazygit",
        -- Keymaps for lazygit
        keymaps = {
          ["<C-n>"] = { "j", "down" },
          ["<C-p>"] = { "k", "up" },
          ["<C-s>"] = { "s", "stash" },
          ["<C-r>"] = { "R", "rebase" },
          ["<C-m>"] = { "M", "merge" },
          ["<C-c>"] = { "q", "quit" },
        },
        -- Customize the floating window
        floating = true,
        -- Border of the floating window
        border = "rounded",
        -- Keymaps for the floating window
        keymaps = {
          ["<C-c>"] = { "q", "quit" },
        },
        -- Customize the terminal
        terminal = {
          size = {
            width = 0.9,
            height = 0.9,
          },
          position = "center",
        },
        -- Callback when lazygit is opened
        on_open = function()
          store_current_buffer()
        end,
        -- Callback when lazygit is closed
        on_close = function()
          return_to_previous_buffer()
        end,
      }
    end,
  },
} 