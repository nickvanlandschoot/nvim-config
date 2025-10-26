# Claude Diff Tests

Comprehensive test suite for the Claude Diff plugin to catch bugs before they reach production.

## Prerequisites

The tests require [plenary.nvim](https://github.com/nvim-lua/plenary.nvim):

```vim
:Lazy install plenary.nvim
```

## Running Tests

### Run all tests:
```bash
cd ~/.config/nvim
nvim --headless -c "lua require('plenary.test_harness').test_directory('tests/claude_diff')" -c "qa!"
```

### Run a specific test file:
```bash
nvim --headless -c "PlenaryBustedFile tests/claude_diff/diff_spec.lua" -c "qa!"
```

### Quick command (add to your shell):
```bash
alias nvim-test="cd ~/.config/nvim && nvim --headless -c \"lua require('plenary.test_harness').test_directory('tests/claude_diff')\" -c \"qa!\""
```

## Test Organization

```
tests/
├── claude_diff/
│   ├── test_utils.lua      # Testing utilities
│   ├── diff_spec.lua       # Diff calculation tests
│   ├── actions_spec.lua    # Accept/reject action tests
│   └── ...                 # More test files
├── minimal_init.lua        # Minimal config for tests
└── README.md               # This file
```

## What's Tested

### diff_spec.lua
- ✓ Detecting additions
- ✓ Detecting deletions
- ✓ Detecting changes
- ✓ Multiple hunks
- ✓ Baseline updates after accept
- ✓ Baseline updates after reject

### actions_spec.lua
- ✓ Accept single hunk (add/delete/change)
- ✓ Reject single hunk
- ✓ Accept all hunks
- ✓ Reject all hunks
- ✓ Multiple hunks handling
- ✓ Buffer state after operations
- ✓ Baseline state after operations

## Writing New Tests

Use the test utilities in `test_utils.lua`:

```lua
local utils = require("tests.claude_diff.test_utils")

it("my test", function()
  -- Create test data
  local baseline = { "line1", "line2" }
  local current = { "line1", "modified", "line2" }

  -- Create buffer and state
  local buf = utils.create_test_buffer(current)
  local st = utils.create_test_state(baseline, current)

  -- Your test logic here

  -- Cleanup
  vim.api.nvim_buf_delete(buf, { force = true })
end)
```

## Debugging Tests

To see detailed output:

```lua
local utils = require("tests.claude_diff.test_utils")

-- Print buffer contents
utils.print_buffer(buf)

-- Print state
utils.print_state(st)
```

## CI Integration

To run tests in CI:

```yaml
- name: Run tests
  run: |
    nvim --headless -c "lua require('plenary.test_harness').test_directory('tests/claude_diff')" -c "qa!"
```
