# Nvim Config

A modern Neovim setup with curated plugins for LSP, debugging, AI, search, and Git workflows. Optimized for TypeScript, Python, and frontend/backend development with fast startup, reliable diagnostics, and practical defaults across projects.

Built for day-to-day engineering work across web, API, and scripting repos, this config prioritizes consistency: fast file navigation, accurate completions, robust formatting/linting feedback, and repeatable debugging flows. It pairs a lightweight plugin stack with focused UX defaults so you can move between coding, refactoring, and troubleshooting quickly, while keeping the setup flexible enough to adapt as your workflow evolves.

The goal is to keep friction low and signal high: quick file access, clear diagnostics, stable project context, and predictable edits whether you are writing TypeScript, Python, or Lua. It includes tuned defaults for LSP-driven development, git-aware workflows, and interactive tooling (search, AI assistance, and debugging) so you can stay in motion from first open file to a clean patch.

## Installation

- Optionally fork for a separate config
- clone into ~/.config/nvim (for unix & mac)
- run nvim

## Plugins

- lazy (package manager)
- telescope (searching)
- treesitter (syntax highlighting)
- lualine (status bar)
- nvim-tree (file explorer tree)
- dap (debugging)
- blink (autocomplete)
- neocodeium (AI autocomplete powered by Windsurf)
- claudecode (AI chat and code assistance with tab support)

## Vim Settings

- tab width & indentation is two spaces
- swap files disabled, persistent undo enabled
- automatic file change detection on focus/buffer enter
- graceful external file conflict handling

## Keybindings

### general

- <Space>+ff toggles telescope file search
- <Space>+fg toggles telescope global grep
- <Space>+fr opens global find and replace with ripgrep
- <Space>+gs opens git status in Telescope (changed files picker)
- <Space>+gd opens git diff in Telescope for changed files
- <Space>+d shows a floating diagnostic window
- [d / ]d jump to previous/next diagnostic
- <Space>+dc continue/start debug session
- <Space>+dg copies all diagnostics to clipboard
- <Space>+y copy selection to clipboard
- <Space>+p paste from clipboard
- <Space>+cp copy current file path
- <Space>+cP copy absolute file path
- <C-s> open a horizontal split
- <C-p> open a vertical split
- <C-q> close current window/split

### file explorer

- <Space>+e toggles nvim-tree file explorer
- <Space>+E reveals current file in nvim-tree
- `-` opens Oil file explorer (current directory)

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
- **Elixir** - Phoenix server debugging support

**Debug Configurations Available:**

- 📄 **Launch current file** - Debug the currently open JS/TS file
- 🌐 **Launch Node.js** - Standard Node.js application debugging
- 🔗 **Attach to process** - Connect to running Node.js process
- ⚛️ **React App** - Debug React applications in Chrome (localhost:3000)
- 🚀 **Next.js** - Debug Next.js applications with proper source mapping
- 🐍 **Python scripts** - Debug Python applications with virtual environment support

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
