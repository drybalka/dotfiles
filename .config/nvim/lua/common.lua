require 'paq' {
  'savq/paq-nvim', -- Let Paq manage itself
  'nvim-lua/plenary.nvim', -- common dependency

  -- keymap
  'drybalka/clean.nvim',

  -- general
  'folke/neodev.nvim',
  'sainnhe/gruvbox-material',

  -- lsp
  'neovim/nvim-lspconfig',
  'scalameta/nvim-metals',
  'stevearc/conform.nvim',
  'hrsh7th/cmp-nvim-lsp',
  'ThePrimeagen/refactoring.nvim',
  'SmiteshP/nvim-navbuddy',
  'SmiteshP/nvim-navic', -- dependency of navbuddy
  'MunifTanjim/nui.nvim', -- dependency of navbuddy

  -- cmp
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'L3MON4D3/LuaSnip',
  'saadparwaiz1/cmp_luasnip',
  'rafamadriz/friendly-snippets',
  'onsails/lspkind.nvim',

  -- git
  'lewis6991/gitsigns.nvim',
  'sindrets/diffview.nvim',
  'akinsho/toggleterm.nvim',

  -- telescope
  'nvim-telescope/telescope.nvim',
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
  },
  'nvim-telescope/telescope-file-browser.nvim',
  'kyazdani42/nvim-web-devicons', -- optional dependency of telescope

  -- dap
  'mfussenegger/nvim-dap',
  'rcarriga/nvim-dap-ui',
  'mfussenegger/nvim-dap-python',
  'jbyuki/one-small-step-for-vimkind',

  -- test
  'nvim-neotest/neotest',
  -- 'stevanmilic/neotest-scala',

  -- treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdateSync',
  },
  'drybalka/tree-climber.nvim',

  -- misc
  'nvim-lualine/lualine.nvim',
  'lukas-reineke/indent-blankline.nvim',
  'asiryk/auto-hlsearch.nvim',
  'kylechui/nvim-surround',
  'chrisgrieser/nvim-spider',
  'stevearc/dressing.nvim',
  'echasnovski/mini.comment',
  'JoosepAlviste/nvim-ts-context-commentstring',
  'folke/twilight.nvim',
}

require 'common.keymap'
require 'common.general'
require 'common.lsp'
require 'common.git'
require 'common.telescope'
require 'common.misc'
require 'common.cmp'
require 'common.dap'
require 'common.test'
require 'common.treesitter'
require 'common.openai'
