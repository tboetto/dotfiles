-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use'wbthomason/packer.nvim'

  use {
	  'nvim-telescope/telescope.nvim', tag='0.1.5',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  use {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v3.x',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},
		  {'williamboman/mason.nvim'},
	  	{'williamboman/mason-lspconfig.nvim'},

	  -- Autocompletion
	  {'hrsh7th/nvim-cmp'},     -- Required
	  {'hrsh7th/cmp-nvim-lsp'}, -- Required

	  {'hrsh7th/cmp-buffer'},
	{'hrsh7th/cmp-path'},
	{'hrsh7th/cmp-nvim-lua'},
	{'rafamadriz/friendly-snippets'},
	{'saadparwaiz1/cmp_luasnip'},

	  {'L3MON4D3/LuaSnip'},     -- Required
  }
}

use {
  'nvim-tree/nvim-tree.lua',
  requires = {
    'nvim-tree/nvim-web-devicons', -- optional
  },
}

  use'navarasu/onedark.nvim'


  use ('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })

  use'nvim-treesitter/playground'
  use'ThePrimeagen/harpoon'
  use'mbbill/undotree'
  use'tpope/vim-fugitive'
  use'tpope/vim-surround'
  use'jreybert/vimagit'
  use { 'joeveiga/ng.nvim'}
  use'christoomey/vim-tmux-navigator'
  use'romainl/vim-cool'
  use'simeji/winresizer'



end)

