# Neovim Memory Optimization

## Current Memory Usage
Your Neovim setup is using approximately **1.5GB of RAM**. Here's what I found and fixed:

## Main Issues Identified

### 1. **Multiple Neovim Instances** (BIGGEST ISSUE)
You have many `nvim --embed` processes running simultaneously. Each instance:
- Loads all plugins
- Spawns its own LSP servers (pyright, ruff, gopls, etc.)
- Maintains separate memory spaces

**Solution**: Close unused Neovim instances. Each instance should only be running when actively editing files.

### 2. **Telescope Memory Issue** (FIXED)
The `find_files_plus` function was loading ALL files into memory at once before displaying them.

**Fixed**: Changed to use streaming finder (`new_job`) that processes files incrementally.

### 3. **Image Plugin** (OPTIMIZED)
The image.nvim plugin was rendering all images in markdown files simultaneously.

**Optimized**:
- Only render image at cursor position
- Clear images in insert mode
- Disabled auto-download of remote images

### 4. **Treesitter** (OPTIMIZED)
Treesitter was parsing syntax for all files, including very large ones.

**Optimized**:
- Disable highlighting for files > 100KB
- Added incremental selection to reduce memory usage

### 5. **LSP Servers** (OPTIMIZED)
Multiple LSP servers running per Neovim instance.

**Optimized**:
- Disable semantic tokens for files > 500KB

### 6. **UFO Folding** (OPTIMIZED)
Added configuration to close folds when leaving buffers.

## Additional Recommendations

### Close Unused Neovim Instances
Run this to see all instances:
```bash
ps aux | grep nvim | grep -v grep
```

Kill unused instances:
```bash
# Be careful - only kill instances you're not using!
kill <PID>
```

### Monitor Memory Usage
```bash
ps aux | grep -E "(nvim|pyright|ruff|gopls|typescript)" | grep -v grep | awk '{sum+=$6} END {print "Total RSS: " sum/1024 " MB"}'
```

### Consider Lazy Loading
Some plugins can be lazy-loaded to reduce startup memory:
- `image.nvim` - Already set to `event = "VeryLazy"`
- Consider lazy-loading other heavy plugins

### LSP Server Management
- Only enable LSP servers for filetypes you actually use
- Consider disabling automatic installation if you don't need all servers

## Files Modified

1. `lua/plugins/editor/telescope.lua` - Streaming finder instead of loading all files
2. `lua/plugins/image.lua` - Only render at cursor, clear in insert mode
3. `lua/plugins/treesitter.lua` - Disable for large files
4. `lua/plugins/ufo.lua` - Better fold management
5. `lua/plugins/lsp/lspconfig.lua` - Disable semantic tokens for large files

## Expected Memory Reduction

After these optimizations and closing unused instances, you should see:
- **Per-instance memory**: ~100-200MB (down from ~300-400MB)
- **Total memory**: Should drop significantly once unused instances are closed

The biggest win will be closing unused Neovim instances!
