return {
  "mgierada/lazydocker.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "akinsho/toggleterm.nvim",
  },
  config = function()
    -- Store the current buffer before opening lazydocker
    local function store_current_buffer()
      vim.g.lazydocker_previous_buffer = vim.api.nvim_get_current_buf()
    end

    -- Return to the previous buffer after lazydocker closes
    local function return_to_previous_buffer()
      if vim.g.lazydocker_previous_buffer then
        vim.api.nvim_set_current_buf(vim.g.lazydocker_previous_buffer)
        vim.g.lazydocker_previous_buffer = nil
      end
    end

    -- Setup toggleterm first
    require("toggleterm").setup()

    -- Setup lazydocker configuration
    require("lazydocker").setup({
      -- Command to execute when lazydocker is opened
      cmd = "lazydocker",
      -- Customize the floating window
      floating = true,
      -- Border of the floating window
      border = "rounded",
      -- Customize the terminal
      terminal = {
        size = {
          width = 0.9,
          height = 0.9,
        },
        position = "center",
      },
      -- Callback when lazydocker is opened
      on_open = function()
        store_current_buffer()
      end,
      -- Callback when lazydocker is closed
      on_close = function()
        return_to_previous_buffer()
      end,
    })

    -- Add keymapping to open lazydocker
    vim.keymap.set("n", "<leader>ld", ":Lazydocker<CR>", { noremap = true, silent = true, desc = "Open LazyDocker" })
  end,
} 