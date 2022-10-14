local keyopts = { noremap = true, silent = true }

local climber = require 'tree-climber'

-- Treesitter configuration
require('nvim-treesitter.configs').setup {
  ensure_installed = 'all',
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<M-w>',
      node_incremental = '<M-w>',
      node_decremental = '<M-c-w>',
      scope_incremental = '<M-e>',
    },
  },
  indent = {
    enable = true,
  },
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = { 'BufWrite', 'CursorHold' },
  },
}

-- Allow node movements
-- vim.opt.runtimepath:append("/home/drybalka/code/tree-climber.nvim")
local tree_climber_opts = {
  skip_comments = false,
  highlight = true,
  higroup = '@tag',
}
vim.keymap.set({ 'n', 'v', 'o' }, 'H', function()
  climber.goto_parent(tree_climber_opts)
end, keyopts)
vim.keymap.set({ 'n', 'v', 'o' }, 'L', function()
  climber.goto_child(tree_climber_opts)
end, keyopts)
vim.keymap.set({ 'n', 'v', 'o' }, 'J', function()
  climber.goto_next(tree_climber_opts)
end, keyopts)
vim.keymap.set({ 'n', 'v', 'o' }, 'K', function()
  climber.goto_prev(tree_climber_opts)
end, keyopts)
vim.keymap.set({ 'v', 'o' }, 'in', function()
  climber.select_node(tree_climber_opts)
end, keyopts)
vim.keymap.set('n', '<C-k>', climber.swap_prev, keyopts)
vim.keymap.set('n', '<C-j>', climber.swap_next, keyopts)
vim.keymap.set('n', '<C-h>', function()
  climber.highlight_node()
end, keyopts)
