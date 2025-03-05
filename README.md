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

## Vim Settings
- tab width & indentation is two spaces

## Keybindings

### general
- <Space>+e toggles nvimtree 
- <Space>+ff toggles telescope file search
- <Space>+fg toggles telescoge global grep
- <Space>+d shows a floating error window when needed

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

## Configured LSPs
- lua_ls (Lua)
- ts_ls (Typescript, React)
- pyright (Python)
- jsonls (JSON)
- yamlls (YAML)

## Credits

Some parts of config loosely based on this [https://www.youtube.com/playlist?list=PLsz00TDipIffreIaUNk64KxTIkQaGguqn](guide) by [https://www.youtube.com/@typecraft_dev](typecraft) on setting up nvim.
