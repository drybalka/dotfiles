local keyopts = { noremap = true, silent = true }

local gitsigns = require 'gitsigns'
local diffview = require 'diffview'
local telescope_builtins = require 'telescope.builtin'

gitsigns.setup {
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, opts)
      opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
      vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end

    -- Navigation
    map('n', ']h', "&diff ? ']c' : '<Cmd>Gitsigns next_hunk<CR>'", { expr = true })
    map('n', '[h', "&diff ? '[c' : '<Cmd>Gitsigns prev_hunk<CR>'", { expr = true })
  end,
}
vim.keymap.set('n', '<Leader>hp', gitsigns.preview_hunk, keyopts)
vim.keymap.set({ 'n', 'v' }, '<Leader>hr', gitsigns.reset_hunk, keyopts)

local terminal
vim.keymap.set('n', '<Tab>tt', function()
  local window_opts = {
    minwidth = math.floor(vim.o.columns * 0.9),
    minheight = math.floor(vim.o.lines * 0.9),
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    borderhighlight = 'TelescopeBorder',
  }
  if terminal ~= nil then
    require('plenary.popup').create(terminal, window_opts)
  else
    terminal = vim.api.nvim_create_buf(false, false)
    require('plenary.popup').create(terminal, window_opts)
    vim.fn.termopen(os.getenv 'SHELL')
    vim.keymap.set('t', '<C-[>', function()
      vim.api.nvim_win_close(0, false)
    end, { buffer = terminal })
  end
  vim.cmd 'startinsert'
end, keyopts)

local diffview_actions = require 'diffview.actions'
local diffview_select = function()
  diffview_actions.goto_file_edit()
  for _, view in pairs(require('diffview.lib').views) do
    view:close()
  end
end
diffview.setup {
  enhanced_diff_hl = true, -- See |diffview-config-enhanced_diff_hl|
  keymaps = {
    disable_defaults = true,
    view = {
      ['<C-[>'] = ':DiffviewClose<CR>',
    },
    file_panel = {
      ['<C-[>'] = ':DiffviewClose<CR>',
      { 'n', 'j', diffview_actions.select_next_entry, { desc = 'Next entry' } },
      { 'n', '<C-n>', diffview_actions.select_next_entry, { desc = 'Next entry' } },
      { 'n', 'k', diffview_actions.select_prev_entry, { desc = 'Previous entry' } },
      { 'n', '<C-p>', diffview_actions.select_prev_entry, { desc = 'Previous entry' } },
      { 'n', '<CR>', diffview_select, { desc = 'Open the file' } },
      { 'n', 'l', diffview_select, { desc = 'Open the file' } },
      { 'n', '<C-d>', diffview_actions.scroll_view(0.25), { desc = 'Scroll the view down' } },
      { 'n', '<C-u>', diffview_actions.scroll_view(-0.25), { desc = 'Scroll the view up' } },
      { 'n', '<C-/>', diffview_actions.help 'file_panel', { desc = 'Open the help panel' } },
      { 'n', '-', diffview_actions.toggle_stage_entry, { desc = 'Stage / unstage the selected entry' } },
      { 'n', 'S', diffview_actions.stage_all, { desc = 'Stage all entries' } },
      { 'n', 'U', diffview_actions.unstage_all, { desc = 'Unstage all entries' } },
    },
    help_panel = {
      { 'n', '<esc>', diffview_actions.close, { desc = 'Close help menu' } },
    },
  },
  hooks = {
    diff_buf_read = function()
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end,
  },
}
vim.keymap.set('n', '<Tab>gd', ':DiffviewOpen<CR>', keyopts)

vim.keymap.set('n', '<Tab>gs', telescope_builtins.git_status, keyopts)
vim.keymap.set('n', '<Tab>gb', telescope_builtins.git_branches, keyopts)
vim.keymap.set('n', '<Tab>gc', telescope_builtins.git_commits, keyopts)
vim.keymap.set('n', '<Tab>gf', telescope_builtins.git_bcommits, keyopts)
