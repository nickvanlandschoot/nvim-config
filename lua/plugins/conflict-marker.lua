return {
  {
    "rhysd/conflict-marker.vim",
    event = "BufRead",
    config = function()
      -- Customize conflict marker highlighting
      vim.g.conflict_marker_highlight_group = "Error"
      
      -- Customize conflict marker patterns
      vim.g.conflict_marker_begin = "^<<<<<<<\\+ .*$"
      vim.g.conflict_marker_common_ancestors = "^|||||||\\+ .*$"
      vim.g.conflict_marker_separator = "^=======$"
      vim.g.conflict_marker_end = "^>>>>>>>\\+ .*$"
      
      -- Customize highlight colors
      vim.cmd([[
        " Disable default highlight group
        let g:conflict_marker_highlight_group = ''
        
        " Markers
        
        highlight ConflictMarkerBegin ctermbg=red ctermfg=white
        highlight ConflictMarkerEnd ctermbg=red ctermfg=white
        highlight ConflictMarkerSeparator ctermbg=red ctermfg=white
        highlight ConflictMarkerCommonAncestors ctermbg=red ctermfg=white
        
        " Content sections
        highlight ConflictMarkerOurs ctermbg=green ctermfg=black
        highlight ConflictMarkerTheirs ctermbg=red ctermfg=white
        highlight ConflictMarkerCommonAncestorsHunk ctermbg=magenta ctermfg=white
      ]])
      
      -- Enable default mappings
      vim.g.conflict_marker_enable_mappings = 1
      vim.g.conflict_marker_enable_highlight = 1
      vim.g.conflict_marker_enable_matchit = 1
    end,
  },
} 