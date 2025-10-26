# Nvim Config

Test

Test
Test
Test
New

ReA comprehensive Neovim configuration with modern plugins, LSP support, debugging capabilities, and intelligent file management. Features include syntax highlighting, autocomplete, Git integration, and support for multiple programming languages including TypeScript, Python, Go, and LaTeX.

## Installation

- Optionally fork for a separate config

- clone into ~/.config/nvim (for unix & mac)
- run nvim
  Lets delete this section

Lets delete this section
Lets delete this section
Lets delete this section

- clone into ~/.config/nvim (for unix & mac)
- run nvim
- Optionally fork for a separate config

- clone into ~/.config/nvim (for unix & mac)
  Lets delete this section
- run nvim
- clone into ~/.config/nvim (for unix & mac)
  Lets delete this section

## Plugins

- barbar (visual tabs)
- lazy (package manager)
- catppuccin (for theme)
- nvim-tree (visual sidebar)
- telescope (searching)
- treesitter (syntax highlighting)
- lualine (status bar)
- dap (debugging)
- blink (autocomplete)
- github/copilot.nvim (AI autocomplete, chat, and code suggestions)
- harpoon (quick file navigation)
- conflict-marker (Git conflict resolution)
- cursor.nvim (custom cursor diff tool)
- octo.nvim (GitHub PR and issue management)
- lazygit (Git TUI in floating window)
- claude-inline.nvim (Cursor-style inline AI editing with Claude)
- claude-diff (Live diff viewer for Claude's file changes)

## Vim Settings

- tab width & indentation is two spaces
- swap files disabled, persistent undo enabled
- automatic file change detection on focus/buffer enter
- graceful external file conflict handling

## Keybindings

### general

- <Space>+e toggles nvimtree
- <Space>+ff toggles telescope file search
- <Space>+fg toggles telescope global grep
- <Space>+fr opens global find and replace with ripgrep
- <Space>+fh opens Harpoon marks in Telescope
- <Space>+gs opens git status in Telescope (changed files picker)
- <Space>+d shows a floating error window when needed
- <Space>+dc copy diagnostics to clipboard

### harpoon

- <Space>+a adds current file to Harpoon
- <C-e> toggles Harpoon quick menu
- <C-h> jumps to Harpoon mark 1
- <C-j> jumps to Harpoon mark 2
- <C-k> jumps to Harpoon mark 3
- <C-l> jumps to Harpoon mark 4

### cursor.nvim (Custom Diff Tool)

**Features:**

- 📸 **Automatic snapshots** - Takes snapshots of your code on every save
- 🔍 **Visual diff viewer** - Shows changes between current state and snapshots
- ⚡ **Zero configuration** - Works out of the box

**Usage:**

- `:CursorDiff` - Open the diff viewer to see changes since last save

### treesitter collapsing

- zc collapses a fold
- zo opens a fold
- za toggles a fold
- zM closes all folds
- zR opens all folds

### debugging

- continue '<F1>'
- step_into '<F2>'
- step_over '<F3>'
- step_out '<F4>'
- step_back '<F5>'
- breakpoint '<F6>'
- restart '<F13>'

**Enhanced Debug Features:**

- `<Space>+ds` - 🎯 **Select debug configuration** - Shows menu to choose from available configurations
- `<Space>+dc` - ▶️ **Debug continue/start** - Starts debugging or continues if already running
- `<Space>+dl` - 🔄 **Run last configuration** - Quickly re-run the previous debug session
- `<Space>+b` - 🔴 **Toggle breakpoint** - Set/remove breakpoint at current line
- `<Space>+gb` - 🏃 **Run to cursor** - Run until cursor position
- `<Space>+?` - 🔍 **Evaluate expression** - Hover over variables or evaluate custom expressions

**Supported Languages:**

- **JavaScript/Node.js** - Multiple launch configurations including current file and attach modes
- **TypeScript** - Both ts-node and compiled JavaScript debugging with source maps
- **React/JSX** - Frontend debugging with Chrome DevTools integration
- **Python** - Full debugging support with uv/pip environments
- **Go** - Native Go debugging with Delve
- **Elixir** - Phoenix server debugging support

**Debug Configurations Available:**

- 📄 **Launch current file** - Debug the currently open JS/TS file
- 🌐 **Launch Node.js** - Standard Node.js application debugging
- 🔗 **Attach to process** - Connect to running Node.js process
- ⚛️ **React App** - Debug React applications in Chrome (localhost:3000)
- 🚀 **Next.js** - Debug Next.js applications with proper source mapping
- 🐍 **Python scripts** - Debug Python applications with virtual environment support

### git conflicts

- `[x` and `]x` to jump between conflict markers
- `%` to jump within conflict blocks
- `ct` to use their version
- `co` to use our version
- `cn` to use neither version
- `cb` to use both versions
- `cB` to use both versions in reverse order

### lazygit

- `<Space>+gg` opens lazygit in a floating window
- `<C-n>` move down
- `<C-p>` move up
- `<C-s>` stash changes
- `<C-r>` rebase
- `<C-m>` merge
- `<C-c>` quit

### claude-inline.nvim (AI Inline Editing)

**Features:**

- Visual mode AI editing - Select text and apply AI-powered transformations
- Inline prompts - Floating window interface for entering edit instructions
- Preview changes - Optional diff preview before applying changes
- Smart indentation - Preserves original indentation patterns
- Undo support - All edits can be undone with regular Neovim undo

**Usage:**

1. Select text in visual mode (v, V, or Ctrl-V)
2. Press `<C-k>` to trigger inline edit
3. Type your instruction in the floating prompt
4. Press `<CR>` to apply the edit or `<Esc>` to cancel
5. If preview is enabled, review changes and press `<CR>` to accept or `<Esc>` to reject

**Keybindings:**

- `<C-k>` (in visual mode) - Trigger Claude inline edit
- `<CR>` - Accept AI suggestion/changes
- `<Esc>` - Cancel operation
- `<C-u>` - Scroll up in preview window
- `<C-d>` - Scroll down in preview window

**Example Instructions:**

- "Convert this to TypeScript"
- "Add error handling"
- "Refactor to use async/await"
- "Add JSDoc comments"
- "Make this more idiomatic"
- "Optimize this algorithm"

**Note:** Requires Claude Code CLI to be installed and available in your PATH.

### claude-diff (Live Diff Viewer)

**Features:**

- Live inline diffs - Shows Claude's file changes with visual highlights
- Deleted text preview - Deletion hunks show the removed content as virtual lines
- Conflict detection - Automatically marks hunks that overlap with your edits
- Accept/reject/merge - Review and apply changes selectively
- Telescope integration - Browse all diffs with inline preview
- Smart baseline tracking - Maintains history for proper diff resolution
- Session persistence - Hunks persist between Neovim sessions
- Dynamic adjustment - Hunks automatically shift when you edit above them

**How it Works:**

1. Claude modifies a file externally (via Claude Code CLI)
2. Plugin automatically detects the change and shows inline diffs
3. You can review, accept, reject, or merge each change (hunk)
4. Changes that overlap with your edits are marked as conflicts

**Navigation:**

- `]h` - Jump to next Claude hunk
- `[h` - Jump to previous Claude hunk

**Hunk Actions:**

- `<Space>+ha` - Accept Claude's changes (overwrite current)
- `<Space>+hr` - Reject Claude's changes (keep current)
- `<Space>+hb` - Accept both (creates conflict markers for manual merge)
- `<Space>+hl` - List all hunks in current buffer (Telescope)
- `<Space>+hL` - List all hunks across project (Telescope)

**Commands:**

- `:ClaudeNextDiff` - Navigate to next diff hunk
- `:ClaudePrevDiff` - Navigate to previous diff hunk
- `:ClaudeAcceptHunk` - Accept the hunk at cursor
- `:ClaudeRejectHunk` - Reject the hunk at cursor
- `:ClaudeAcceptBoth` - Create conflict markers with both versions
- `:ClaudeAcceptAll` - Accept all Claude changes in current buffer
- `:ClaudeRejectAll` - Reject all Claude changes in current buffer
- `:ClaudeDiffs` - Open Telescope picker for current buffer's diffs
- `:ClaudeProjectDiffs` - Open Telescope picker for all diffs across project

**Telescope Picker Actions:**

- `<CR>` - Jump to selected diff
- `a` - Accept selected hunk
- `r` - Reject selected hunk
- `b` - Accept both (create conflict markers)
- `<C-a>` - Accept (insert mode)
- `<C-r>` - Reject (insert mode)
- `<C-b>` - Accept both (insert mode)

**Visual Highlights:**

- Green (DiffAdd) - Claude added new code
- Blue (DiffChange) - Claude modified existing code
- Red (DiffDelete) - Claude removed code (deleted lines shown as virtual text below)
- Red highlight (ErrorMsg) - Conflict: both you and Claude edited this area

**Workflow Example:**

1. You're editing a file, make some changes
2. Claude modifies the same file via CLI
3. You see inline diffs appear automatically (within 3 seconds or on cursor move)
4. Navigate with `]h` and `[h`
5. For each hunk: accept (`<Space>+ha`), reject (`<Space>+hr`), or merge (`<Space>+hb`)
6. Conflicted hunks (red) indicate overlap with your edits
7. Use `<Space>+hb` on conflicts to create merge markers
8. Or use `<Space>+hl` to review all diffs in Telescope

**Configuration:**

```lua
require("claude_diff").setup({
  keymaps = true,           -- Enable default keymaps (set to false to disable)
  check_interval = 3000,    -- Check for file changes every 3 seconds (in milliseconds)
})
```

**Testing:**
The plugin includes a comprehensive test suite to ensure reliability:

- Run tests: `:ClaudeRunTests` (requires plenary.nvim)
- See `tests/README.md` for detailed testing documentation

**Note:** The plugin uses multiple detection methods:

- Automatic periodic checking (every 3 seconds by default)
- On cursor movement or focus changes
- On external file modifications (via `FileChangedShellPost`)
  Adjust `check_interval` to balance responsiveness vs performance (lower = more responsive, higher = less CPU usage).

### octo.nvim (GitHub Integration)

**Setup:**
Octo.nvim integrates GitHub directly into Neovim with all TUI elements displayed in floating windows. You'll need to authenticate first:

1. Install GitHub CLI: `brew install gh` (or your package manager)
2. Authenticate: `gh auth login`
3. That's it! Octo will use your GitHub CLI credentials

**Common Workflows:**

_Creating a Pull Request:_

1. Make your changes and commit them
2. Press `<Space>+gpc` to create a PR
3. Fill in the title and description in the floating window
4. Save and close the buffer to create the PR

_Reviewing a Pull Request:_

1. Press `<Space>+gpr` to list PRs
2. Select a PR from Telescope
3. Press `<Space>+gvs` to start review
4. Navigate through files and add comments with `<Space>+gpa`
5. Press `<Space>+gvt` to submit your review

_Commenting on Issues/PRs:_

1. Open the PR/issue (via `<Space>+gpr` or `<Space>+gir`)
2. Press `<Space>+gpa` to add a comment in a floating window
3. Write your comment and save

_Quick PR Checkout:_

1. Press `<Space>+gpr` to list PRs
2. Select the PR you want
3. Press `<Space>+gpp` to checkout the PR branch

**Pull Request Operations:**

- `<Space>+gpr` - List PRs in Telescope
- `<Space>+gpc` - Create new PR (opens in floating window)
- `<Space>+gps` - Search PRs
- `<Space>+gpe` - Edit current PR
- `<Space>+gpp` - Checkout PR
- `<Space>+gpd` - View PR diff
- `<Space>+gpm` - Merge PR
- `<Space>+gpo` - Open PR in browser

**Issue Operations:**

- `<Space>+gir` - List issues in Telescope
- `<Space>+gic` - Create new issue (opens in floating window)
- `<Space>+gis` - Search issues
- `<Space>+gie` - Edit current issue
- `<Space>+gio` - Open issue in browser

**Review Operations:**

- `<Space>+gvs` - Start PR review
- `<Space>+gvr` - Resume review
- `<Space>+gvc` - View review comments
- `<Space>+gvt` - Submit review
- `<Space>+gvd` - Discard review

**Comment Operations:**

- `<Space>+gpa` - Add comment (opens in floating window)
- `<Space>+gcd` - Delete comment
- `]c` / `[c` - Navigate next/prev comment

**Reaction Operations:**

- `<Space>+grt` - React with thumbs up
- `<Space>+grh` - React with heart
- `<Space>+gre` - React with eyes
- `<Space>+grr` - React with rocket

**Thread Navigation:**

- `<Space>+gtn` - Next thread
- `<Space>+gtp` - Previous thread
- `]t` / `[t` - Next/prev thread in review

**Label Operations:**

- `<Space>+gla` - Add label
- `<Space>+gld` - Remove label
- `<Space>+glc` - Create label

**Other Operations:**

- `<Space>+ggl` - List gists
- `<Space>+gsp` - Search GitHub
- `<leader>gb` - Open in browser (when in PR/issue buffer)
- `<leader>yu` - Copy URL (when in PR/issue buffer)
- `gf` - Go to file (when in PR diff)

## Global Find and Replace

### Powerful Search and Replace with Ripgrep

- **Interactive find and replace** - Search across your entire project using ripgrep
- **Multi-file support** - Replace text across multiple files simultaneously
- **Visual selection** - Preview all matches before replacing
- **Selective replacement** - Choose which matches to replace using Tab to select multiple entries

### Usage

1. Press `<Space>+fr` to open global find and replace
2. Enter your search term (supports regex patterns)
3. Enter your replacement text
4. Use Tab to select multiple matches or Enter to replace current selection
5. Press Enter to perform the replacement

**Features:**

- 🔍 **Ripgrep integration** - Fast, recursive search across all files
- 🎯 **Regex support** - Use regular expressions for complex patterns
- 📋 **Multi-selection** - Select specific matches to replace
- 💾 **Auto-save** - Modified files are automatically saved after replacement
- 📊 **Progress feedback** - Shows count of replacements made

## File Management

### Automatic File Handling

- **Smart file change detection** - Automatically detects when files are modified externally
- **Conflict resolution** - Interactive prompts when external changes conflict with unsaved changes
  - Keep your changes
  - Reload from disk
  - Show diff with `:DiffOrig`
- **No swap file conflicts** - Swap files disabled in favor of persistent undo

### Utility Commands

- `:FileDebug` - Show detailed file status information
- `:DiffOrig` - Show diff between current buffer and saved file

## Configured LSPs

- lua_ls (Lua)
- ts_ls (Typescript, React)
- pyright (Python)
- jsonls (JSON)
- yamlls (YAML)

## LaTeX Editing

This configuration includes powerful LaTeX editing capabilities with the following features:

### Core Features

- **VimTeX** for comprehensive LaTeX support
  - Automatic compilation with latexmk
  - PDF viewer integration with Zathura
  - Forward and inverse search
  - Syntax highlighting and concealment
  - Table of contents navigation
  - Error detection and navigation

### Key Bindings

- `<leader>ll` - Compile LaTeX document
- `<leader>lv` - View PDF
- `<leader>lc` - Clean auxiliary files
- `<leader>lt` - Toggle Table of Contents
- `<leader>le` - Show errors

### Real-time Preview

- **knap.nvim** for real-time PDF preview
  - Auto-compilation on save
  - Instant PDF refresh
  - Forward search support

### Key Bindings for Preview

- `<leader>kp` - Toggle auto preview
- `<leader>kf` - Forward search
- `<leader>kr` - Refresh preview
- `<leader>ks` - Stop preview

### Math Editing

- Enhanced math mode support
- Concealed math symbols for cleaner editing
- Automatic compilation of math-heavy documents
- Support for complex mathematical expressions

### Requirements

- Zathura PDF viewer
- latexmk
- pdflatex
- rubber (for error reporting)

## Credits

Some parts of config loosely based on this [https://www.youtube.com/playlist?list=PLsz00TDipIffreIaUNk64KxTIkQaGguqn](guide) by [https://www.youtube.com/@typecraft_dev](typecraft) on setting up nvim.

### TypeScript JSX Configuration

If you're getting **"Cannot use JSX unless the '--jsx' flag is provided [17004]"** errors in TypeScript projects:

**Quick Fix:** Create a `tsconfig.json` file in your project root:

```bash
# Copy the template to your project
cp ~/.config/nvim/tsconfig-template.json ./tsconfig.json
```

**Or create manually with minimum JSX settings:**

```json
{
  "compilerOptions": {
    "jsx": "react-jsx",
    "jsxImportSource": "react",
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*", "*.ts", "*.tsx", "*.js", "*.jsx"]
}
```

**Key JSX Settings:**

- `"jsx": "react-jsx"` - Enables modern JSX transform (React 17+)
- `"jsx": "react"` - For older React versions
- `"jsx": "preserve"` - For Next.js or custom build tools
- `"jsxImportSource": "react"` - Specifies JSX import source

**Alternative JSX options:**

- `"jsx": "react-native"` - For React Native projects
- `"jsx": "preserve"` - Keeps JSX as-is for bundlers like Vite/Next.js
