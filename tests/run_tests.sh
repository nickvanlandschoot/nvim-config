#!/usr/bin/env bash

# Run Claude Diff tests using plenary.nvim
# Usage: ./tests/run_tests.sh [test_file]

set -e

NVIM_CONFIG="$HOME/.config/nvim"
TEST_DIR="$NVIM_CONFIG/tests"

# Check if plenary is installed
if [ ! -d "$HOME/.local/share/nvim/lazy/plenary.nvim" ]; then
    echo "Error: plenary.nvim not found"
    echo "Install it with: :Lazy install plenary.nvim"
    exit 1
fi

# Run tests
if [ -n "$1" ]; then
    # Run specific test file
    echo "Running tests in $1..."
    nvim --headless -c "PlenaryBustedFile $TEST_DIR/$1" -c "qa!"
else
    # Run all tests
    echo "Running all tests..."
    nvim --headless -c "PlenaryBustedDirectory $TEST_DIR/claude_diff { minimal_init = '$TEST_DIR/minimal_init.lua' }" -c "qa!"
fi
