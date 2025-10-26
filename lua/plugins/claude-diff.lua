-- Claude Diff Plugin
-- Live inline diffs for Claude's file changes
return {
  {
    enabled = false, -- Disabled: experimental feature
    dir = vim.fn.stdpath("config") .. "/lua/claude_diff",
    name = "claude-diff",
    config = function()
      require("claude_diff").setup({
        -- Enable default keymaps (set to false to disable)
        keymaps = true,
        -- How often to check for file changes (in milliseconds)
        -- Default: 3000 (3 seconds)
        check_interval = 3000,
      })
    end,
  },
}
