require 'paq' {
  'savq/paq-nvim', -- Let Paq manage itself
  'nvim-lua/plenary.nvim',
  'sainnhe/gruvbox-material',

  'neovim/nvim-lspconfig',

  {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      vim.cmd [[:TSUpdate]]
    end,
  },
  'drybalka/tree-climber.nvim',

  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'rafamadriz/friendly-snippets',
  'L3MON4D3/LuaSnip',
  'saadparwaiz1/cmp_luasnip',
  'onsails/lspkind-nvim',
  'jose-elias-alvarez/null-ls.nvim',
  'ThePrimeagen/refactoring.nvim',

  'lewis6991/gitsigns.nvim',
  'sindrets/diffview.nvim',
  'numToStr/FTerm.nvim',

  'mfussenegger/nvim-dap',
  'jbyuki/one-small-step-for-vimkind',

  'nvim-telescope/telescope.nvim',
  { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  'nvim-telescope/telescope-file-browser.nvim',
  'kyazdani42/nvim-web-devicons',
  'tami5/sqlite.lua',

  'stevearc/dressing.nvim',
  'numToStr/Comment.nvim',
  'lukas-reineke/indent-blankline.nvim',
  'edluffy/specs.nvim',
  'nvim-lualine/lualine.nvim',
  'folke/twilight.nvim',
  'kylechui/nvim-surround',
}

require 'common.general'
require 'common.lsp'
require 'common.git'
require 'common.telescope'
require 'common.misc'
require 'common.cmp'
require 'common.dap'
require 'common.treesitter'
