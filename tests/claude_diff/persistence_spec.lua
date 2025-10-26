-- Tests for session persistence
describe("Claude Diff - Persistence", function()
  local persistence = require("claude_diff.persistence")
  local diff = require("claude_diff.diff")
  local utils = require("tests.claude_diff.test_utils")

  local test_file = "/tmp/test_file.lua"
  local state_dir = vim.fn.expand("~/.local/state/nvim/claude_diff")

  before_each(function()
    -- Create test file
    vim.fn.writefile({ "line1", "line2", "line3" }, test_file)
  end)

  after_each(function()
    -- Clean up test file and state
    vim.fn.delete(test_file)
    local state_file = persistence.get_state_file(test_file)
    if vim.fn.filereadable(state_file) == 1 then
      vim.fn.delete(state_file)
    end
  end)

  describe("save_state and load_state", function()
    it("saves and loads state correctly", function()
      local baseline = { "line1", "line2", "line3" }
      local current = { "line1", "changed2", "line3" }

      local st = utils.create_test_state(baseline, current)
      st.path = test_file
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      -- Save state
      persistence.save_state(test_file, st)

      -- Load state
      local loaded = persistence.load_state(test_file)

      assert.is_not_nil(loaded)
      assert.are.same(baseline, loaded.baseline.lines)
      assert.equals(1, #loaded.hunks)
      assert.equals("change", loaded.hunks[1].kind)
    end)

    it("returns nil for non-existent state", function()
      local loaded = persistence.load_state("/nonexistent/file.lua")
      assert.is_nil(loaded)
    end)

    it("invalidates state if file mtime changed", function()
      local baseline = { "line1", "line2", "line3" }
      local st = utils.create_test_state(baseline, baseline)
      st.path = test_file

      -- Save state
      persistence.save_state(test_file, st)

      -- Modify the file
      vim.fn.system("sleep 0.1")  -- Ensure mtime changes
      vim.fn.writefile({ "line1", "changed2", "line3" }, test_file)

      -- Load should return nil because mtime doesn't match
      local loaded = persistence.load_state(test_file)
      assert.is_nil(loaded)
    end)
  end)

  describe("cleanup_old_states", function()
    it("removes state files older than 30 days", function()
      -- This test would require mocking file timestamps
      -- For now, we'll just verify the function exists and doesn't error
      local success = pcall(persistence.cleanup_old_states)
      assert.is_true(success)
    end)
  end)

  describe("get_state_file", function()
    it("generates consistent state file paths", function()
      local path1 = persistence.get_state_file("/path/to/file.lua")
      local path2 = persistence.get_state_file("/path/to/file.lua")

      assert.equals(path1, path2)
      assert.is_true(vim.startswith(path1, state_dir))
    end)

    it("generates different paths for different files", function()
      local path1 = persistence.get_state_file("/path/to/file1.lua")
      local path2 = persistence.get_state_file("/path/to/file2.lua")

      assert.is_not.equals(path1, path2)
    end)
  end)
end)
