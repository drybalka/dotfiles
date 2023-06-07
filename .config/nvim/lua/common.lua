require 'paq' {
  'savq/paq-nvim', -- Let Paq manage itself
  'nvim-lua/plenary.nvim',
  'sainnhe/gruvbox-material',

  'neovim/nvim-lspconfig',
  'scalameta/nvim-metals',
  'folke/neodev.nvim',
  'lukas-reineke/lsp-format.nvim',

  {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      vim.cmd [[:TSUpdateSync]]
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

  'MunifTanjim/nui.nvim',
  'SmiteshP/nvim-navic',
  'SmiteshP/nvim-navbuddy',

  'lewis6991/gitsigns.nvim',
  'sindrets/diffview.nvim',

  'mfussenegger/nvim-dap',
  'rcarriga/nvim-dap-ui',
  'mfussenegger/nvim-dap-python',
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
  'chrisgrieser/nvim-spider',
  'asiryk/auto-hlsearch.nvim',
}

-- vim.opt.runtimepath:append("/home/drybalka/code/tree-climber.nvim")

require 'common.general'
require 'common.lsp'
require 'common.git'
require 'common.telescope'
require 'common.misc'
require 'common.cmp'
require 'common.dap'
require 'common.treesitter'
