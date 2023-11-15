local neotest = require 'neotest'
local scala = require 'neotest-scala'

neotest.setup {
  floating = {
    max_height = 0.9,
    max_width = 0.9,
  },
  quickfix = {
    enabled = false,
  },
  output_panel = {
    open = '',
  },
  summary = {
    enabled = false,
  },
  adapters = { scala { framework = 'munit' } },
}

vim.keymap.set('n', ']t', neotest.jump.next, { desc = 'Test next' })
vim.keymap.set('n', '[t', neotest.jump.prev, { desc = 'Test prev' })

vim.keymap.set('n', '<Tab>t', function()
  vim.api.nvim_open_win(0, true, {
    relative = 'win',
    row = 2,
    col = 4,
    width = vim.api.nvim_win_get_width(0) - 10,
    height = vim.api.nvim_win_get_height(0) - 4,
    border = 'rounded',
    title = ' Test output ',
    title_pos = 'center',
  })
  neotest.output_panel.open()
  vim.keymap.set('n', '<C-[>', function()
    vim.api.nvim_win_close(0, false)
  end, { buffer = true })
  vim.api.nvim_feedkeys('G', 'n', true)
end, { desc = 'Test output panel' })

vim.keymap.set('n', '<Leader>tr', neotest.run.run, { desc = 'Test run' })
vim.keymap.set('n', '<Leader>tR', function()
  neotest.run.run(vim.fn.expand '%')
end, { desc = 'Test run all' })
vim.keymap.set('n', '<Leader>tl', neotest.run.run_last, { desc = 'Test run last' })
vim.keymap.set('n', '<Leader>ts', neotest.run.stop, { desc = 'Test stop' })
