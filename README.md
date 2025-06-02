# NVim Config

This is my default nvim config that contains various plugins and default settings. 

This is a change

## Installation

- Optionally fork for a seperate config
- clone into ~/.config/nvim (for unix & mac)
- run nvim

## Plugins 

- barbar (visual tabs)
- lazy (package manager)
- gruvbox (for theme)
- nvim-tree (visual sidebar)
- telescope (searching)
- treesitter (syntax highlighting)
- lualine (status bar)
- dap (debugging)
- blink (autocomplete)
- github/copilot.nvim (AI autocomplete, chat, and code suggestions)
- harpoon (quick file navigation)
- conflict-marker (Git conflict resolution)

## Vim Settings
- tab width & indentation is two spaces

## Keybindings

### general
- <Space>+e toggles nvimtree 
- <Space>+ff toggles telescope file search
- <Space>+fg toggles telescoge global grep
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

### git hunks (gitsigns) - Enhanced Visual Mode
**Features:**
- 🎨 **Full line highlighting** - Changed lines are highlighted in their entirety
- 🔍 **Word-level diff** - Individual changed words are highlighted within lines
- 📱 **No sign column clutter** - Clean interface without gutter symbols
- 🎯 **Auto-preview** - Automatic hunk preview when navigating
- ⚡ **Continuous inline diff** - Auto-preview shows when cursor stops on any changed line
- 🔴 **Deleted line indicators** - Shows deleted lines as virtual text (for reference only)
- 🔄 **Two-state toggle** - Switch between minimal gutter signs and full visual mode

**Quick File Overview:**
- `<Space>+gs` - 📋 **Git status picker** - Shows all changed files in floating telescope window

**Toggle Control:**
- `<Space>+gS` - 🔄 **Toggle between two modes:**
  - **📍 Minimal mode**: Just gutter signs (┃, _, ~), no line highlights, no auto-preview
  - **🎨 Full mode**: Complete line + word highlighting with auto-preview + deleted line reference (default)

**Navigation:**
- `]h` / `[h` - Navigate to next/previous change (auto-previews hunk)
- `]H` / `[H` - Jump to last/first change

**Working with Deleted Lines:**
- 🔴 **Deleted lines show as virtual text** but can't be directly interacted with
- **To stage/unstage deleted hunks**: Position cursor on the line **above or below** the deletion
- **Use `]h`/`[h`** to navigate to deletion hunks, then use normal staging commands
- **Preview shows full context** including what was deleted

**Accept/Reject Changes:**
- `<Space>+ha` or `<Space>+y` - ✅ **Accept hunk** (stage it) - works for deletions too
- `<Space>+hr` or `<Space>+n` - ❌ **Reject hunk** (reset it) - works for deletions too
- `<Space>+hA` - ✅ Accept all changes in current file
- `<Space>+hR` - ❌ Reject all changes in current file
- `<Space>+hu` - ↩️ Undo hunk staging (if you change your mind)

**Preview and Info:**
- `<Space>+hp` - 👀 Preview hunk details (shows deleted content)
- `<Space>+hd` - 📊 Show diff for entire file
- `<Space>+hb` - 🕵️ Git blame for current line

**Git Operations:**
- `<Space>+hc` - 💾 Commit accepted changes
- `<Space>+hs` - 📋 Show git status summary

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
