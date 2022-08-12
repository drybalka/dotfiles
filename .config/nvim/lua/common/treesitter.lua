local keyopts = { noremap = true, silent = true }

-- Treesitter configuration
require('nvim-treesitter.configs').setup {
  ensure_installed = 'all',
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<m-w>',
      node_incremental = '<m-w>',
      node_decremental = '<m-c-w>',
      scope_incremental = '<m-e>',
    },
  },
  indent = {
    enable = true,
  },
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = { "BufWrite", "CursorHold" },
  },
}


-- Allow node movements
-- vim.opt.runtimepath:append("/home/drybalka/code/tree-climber.nvim")
local tree_climber_opts = {
  skip_comments = true
}
vim.keymap.set({ 'n', 'v', 'o' }, 'H', function() require('tree-climber').goto_parent(tree_climber_opts) end, keyopts)
vim.keymap.set({ 'n', 'v', 'o' }, 'L', function() require('tree-climber').goto_child(tree_climber_opts) end, keyopts)
vim.keymap.set({ 'n', 'v', 'o' }, 'J', function() require('tree-climber').goto_next(tree_climber_opts) end, keyopts)
vim.keymap.set({ 'n', 'v', 'o' }, 'K', function() require('tree-climber').goto_prev(tree_climber_opts) end, keyopts)
vim.keymap.set({'v', 'o'}, 'in', function() require('tree-climber').select_node(tree_climber_opts) end, keyopts)
vim.keymap.set('n', '<c-k>', require('tree-climber').swap_prev, keyopts)
vim.keymap.set('n', '<c-j>', require('tree-climber').swap_next, keyopts)
-- vim.api.nvim_set_keymap('v', 'in', ':lua require("tree-climber").select_node()<CR>', keyopts)
-- vim.api.nvim_set_keymap('o', 'in', ':lua require("tree-climber").select_node()<CR>', keyopts)
