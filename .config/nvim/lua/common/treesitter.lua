local climber = require 'tree-climber'
local dap = require 'dap'
local treesitter = require 'nvim-treesitter.configs'

-- Treesitter configuration
treesitter.setup {
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
local tree_climber_opts = {
  skip_comments = false,
  highlight = true,
  higroup = '@tag',
}
vim.keymap.set({ 'n', 'v', 'o' }, 'H', function()
  climber.goto_parent(tree_climber_opts)
end, { desc = 'Tree-climber goto parent' })
vim.keymap.set({ 'n', 'v', 'o' }, 'L', function()
  climber.goto_child(tree_climber_opts)
end, { desc = 'Tree-climber goto child' })
vim.keymap.set({ 'n', 'v', 'o' }, 'J', function()
  climber.goto_next(tree_climber_opts)
end, { desc = 'Tree-climber goto next' })
vim.keymap.set({ 'n', 'v', 'o' }, 'K', function()
  climber.goto_prev(tree_climber_opts)
end, { desc = 'Tree-climber goto prev' })
vim.keymap.set({ 'v', 'o' }, 'in', function()
  climber.select_node(tree_climber_opts)
end, { desc = 'Tree-climber select node' })
vim.keymap.set('n', '<C-k>', function()
  if dap.session() ~= nil then
    dap.step_back()
  else
    climber.swap_prev()
  end
end, { desc = 'Tree-climber swap prev / DAP step back' })
vim.keymap.set('n', '<C-j>', function()
  if dap.session() ~= nil then
    dap.step_over()
  else
    climber.swap_next()
  end
end, { desc = 'Tree-climber swap next / DAP step over' })
vim.keymap.set('n', '<C-h>', function()
  if dap.session() ~= nil then
    dap.step_out()
  else
    climber.highlight_node()
  end
end, { desc = 'Tree-climber highlight node / DAP step out' })
vim.keymap.set('n', '<C-l>', function()
  if dap.session() ~= nil then
    dap.step_into()
  else
    vim.cmd 'nohlsearch'
  end
end, { desc = 'DAP step into' })
