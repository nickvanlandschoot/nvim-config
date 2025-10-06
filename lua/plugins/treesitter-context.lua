return {
  "nvim-treesitter/nvim-treesitter-context",
  config = function ()
  	require("treesitter-context").setup({
	  enable=true,
	  multi_window=true,
	  mode='cursor',
    separator = nil
        })
  end
}
