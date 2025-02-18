#NVim Config

This is my default nvim config that contains various plugins and default settings. 

## Installation

- Optionally fork for a seperate config
- clone into ~/.config/nvim (for unix & mac)
- run nvim

## Plugins 

- lazy (package manager)
- catppuccin (for theme):
- nvim-tree (visual sidebar)
- telescope (searching)
- treesitter (syntax highlighting)
- lualine (status bar)
- blink (autocomplete)
- dap (debugging)

## Vim Settings
- tab width & indentation is two spaces

## Keybindings

### general
- <Space>+e toggles nvimtree 
- <Space>+ff toggles telescope file search
- <Space>+fg toggles telescoge global grep

### debugging
- continue <F1>
- step_into <F2>
- step_over <F3> 
- step_out <F4>
- step_back <F5> 
- breakpoint <F6>
- restart <F13>

## Configured LSPs
- lua_ls (Lua)
- ts_ls (Typescript, React)
- pyright (Python)
- jsonls (JSON)
- yamlls (YAML)

## Credits

loosely based on this [https://www.youtube.com/playlist?list=PLsz00TDipIffreIaUNk64KxTIkQaGguqn](guide) by [https://www.youtube.com/@typecraft_dev](typecraft) on setting up nvim.
