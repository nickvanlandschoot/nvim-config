# NVim Config

This is my default nvim config that contains various plugins and default settings. 

## Installation

- Optionally fork for a seperate config
- clone into ~/.config/nvim (for unix & mac)
- run nvim

## Plugins 


- barbar (visual tabs)
- lazy (package manager)
- catppuccin (for theme):
- nvim-tree (visual sidebar)
- telescope (searching)
- treesitter (syntax highlighting)
- lualine (status bar)
- dap (debugging)
- blink (autocomplete)
- Codeium (AI autocomplete)
- harpoon (quick file navigation)
- conflict-marker (Git conflict resolution)
- lazygit (Git interface)


ooo
## Vim Settings
- tab width & indentation is two spaces

## Keybindings

### general
- <Space>+e toggles nvimtree 
- <Space>+ff toggles telescope file search
- <Space>+fg toggles telescoge global grep
- <Space>+fh opens Harpoon marks in Telescope
- <Space>+d shows a floating error window when needed

### harpoon
- <Space>+a adds current file to Harpoon
- <C-e> toggles Harpoon quick menu
- <C-h> jumps to Harpoon mark 1
- <C-j> jumps to Harpoon mark 2
- <C-k> jumps to Harpoon mark 3
- <C-l> jumps to Harpoon mark 4

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

## Credits

Some parts of config loosely based on this [https://www.youtube.com/playlist?list=PLsz00TDipIffreIaUNk64KxTIkQaGguqn](guide) by [https://www.youtube.com/@typecraft_dev](typecraft) on setting up nvim.
