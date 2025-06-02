# VSCode Neovim Integration Setup

This guide explains how to use your Neovim configuration with the VSCode Neovim extension.

## Prerequisites

1. **Install Neovim 0.10.0 or greater**
   ```bash
   # macOS (Homebrew)
   brew install neovim
   
   # Linux (Ubuntu/Debian)
   sudo apt install neovim
   
   # Or download from: https://github.com/neovim/neovim/releases
   ```

2. **Install the VSCode Neovim Extension**
   - Open VSCode
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "vscode-neovim" by asvetliakov
   - Install the extension

## Configuration

### 1. VSCode Settings

Copy the settings from `vscode-settings-example.json` to your VSCode `settings.json`:

- **Windows**: `%APPDATA%\Code\User\settings.json`
- **macOS**: `~/Library/Application Support/Code/User/settings.json`
- **Linux**: `~/.config/Code/User/settings.json`

### 2. Neovim Path Configuration

Update the Neovim executable path in your VSCode settings based on your system:

```json
{
  "vscode-neovim.neovimExecutablePaths.darwin": "/opt/homebrew/bin/nvim",
  "vscode-neovim.neovimExecutablePaths.linux": "/usr/bin/nvim",
  "vscode-neovim.neovimExecutablePaths.win32": "C:\\tools\\neovim\\Neovim\\bin\\nvim.exe"
}
```

To find your Neovim path, run:
```bash
which nvim
```

### 3. Your Neovim Configuration

Your Neovim configuration now automatically detects when running in VSCode:

- **Regular Neovim**: Loads all plugins and full configuration
- **VSCode**: Loads only compatible plugins and VSCode-specific settings

## Key Features

### Automatic Detection
The configuration automatically detects VSCode using `vim.g.vscode` and:
- Disables plugins that conflict with VSCode (syntax highlighting, file trees, etc.)
- Loads VSCode-compatible plugins for enhanced text editing
- Maps Vim commands to VSCode actions for seamless integration

### Key Mappings (VSCode Mode)

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>e` | Toggle Explorer | Open/close file explorer |
| `<leader>ff` | Quick Open | VSCode's quick file search |
| `<leader>fg` | Find in Files | Search across all files |
| `<leader>ca` | Code Actions | Show available code actions |
| `<leader>d` | Next Diagnostic | Jump to next error/warning |
| `<leader>p` | Command Palette | Open VSCode command palette |
| `<leader>t` | Toggle Terminal | Open/close integrated terminal |
| `<leader>/` | Toggle Comment | Comment/uncomment lines |
| `<leader>z` | Zen Mode | Toggle distraction-free mode |
| `gd` | Go to Definition | Navigate to symbol definition |
| `gr` | Go to References | Show all references |
| `K` | Show Hover | Display hover information |
| `=` | Format Selection | Format selected code |
| `<C-d>` | Multi-cursor | Add selection to next match |

### Window Management
- `<C-w>v` - Split editor vertically
- `<C-w>s` - Split editor horizontally  
- `<C-w>q` - Close active editor
- `<C-w>h/j/k/l` - Navigate between editor groups
- `gt/gT` - Next/previous tab

### Line Movement
- `<C-S-j/k>` - Move line/selection up/down

## Compatible Plugins (VSCode Mode)

The following plugins are loaded in VSCode mode for enhanced text editing:

- **nvim-surround** - Surround text objects
- **targets.vim** - Additional text objects
- **dial.nvim** - Enhanced increment/decrement
- **leap.nvim** - Fast motion navigation
- **flit.nvim** - Enhanced f/F/t/T motions
- **vim-repeat** - Better repeat functionality
- **vim-exchange** - Exchange text objects
- **vim-cool** - Better search highlighting
- **vim-indent-object** - Indent text objects
- **vim-abolish** - Case-sensitive search improvements

## Disabled Plugins (VSCode Mode)

These plugins are automatically disabled in VSCode to prevent conflicts:

- Syntax highlighting plugins (VSCode handles this)
- File tree plugins (use VSCode explorer)
- Status line plugins (use VSCode status bar)
- LSP plugins (use VSCode LSP)
- Completion plugins (use VSCode IntelliSense)
- Git plugins (use VSCode Git integration)
- Folding plugins (use VSCode folding)

## Troubleshooting

### Common Issues

1. **Neovim not found**
   - Verify Neovim is installed: `nvim --version`
   - Check the path in VSCode settings matches `which nvim`

2. **Key bindings not working**
   - Ensure no conflicting VSCode extensions (disable VSCodeVim if installed)
   - Check VSCode keybindings don't override Neovim mappings

3. **Visual artifacts or lag**
   - Set `"vscode-neovim.neovimClean": true` to troubleshoot
   - Disable plugins that cause visual effects

4. **Escape key issues on Linux**
   - Add to settings: `"keyboard.dispatch": "keyCode"`

5. **Key repeat on macOS**
   ```bash
   defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
   ```

### Debug Mode

Enable debug logging in VSCode settings:
```json
{
  "vscode-neovim.logLevel": "debug"
}
```

Then check the output: View → Output → Select "vscode-neovim"

## Benefits

Using this setup gives you:

- ✅ Full Vim modal editing in VSCode
- ✅ VSCode's native LSP and IntelliSense
- ✅ Seamless integration with VSCode features
- ✅ Best of both editors
- ✅ Consistent key bindings across environments
- ✅ Plugin compatibility management
- ✅ One configuration for both regular Neovim and VSCode

## Additional Resources

- [VSCode Neovim Extension Documentation](https://github.com/vscode-neovim/vscode-neovim)
- [Neovim Documentation](https://neovim.io/doc/)
- [VSCode Key Binding Reference](https://code.visualstudio.com/docs/getstarted/keybindings) 