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

## Vim Settings & Key Bindings (Default)

- tab width & indentation is two spaces
- <Space>+e toggles nvimtree 
- <Space>+ff toggles telescope file search
- <Space>+fg toggles telescoge global grep

## Configured LSPs
- lua_ls (Lua)
- ts_ls (Typescript, React)
- pyright (Python)
- jsonls (JSON)
- yamlls (YAML)

## Credits

loosely based on this [https://www.youtube.com/playlist?list=PLsz00TDipIffreIaUNk64KxTIkQaGguqn](guide) by [https://www.youtube.com/@typecraft_dev](typecraft) on setting up nvim.
