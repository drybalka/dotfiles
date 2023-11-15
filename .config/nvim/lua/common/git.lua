local gitsigns = require 'gitsigns'
local diffview = require 'diffview'
local telescope_builtins = require 'telescope.builtin'
local toggleterm = require 'toggleterm'

gitsigns.setup()
vim.keymap.set('n', ']h', gitsigns.next_hunk, { desc = 'Git next hunk' })
vim.keymap.set('n', '[h', gitsigns.prev_hunk, { desc = 'Git previous hunk' })
vim.keymap.set('n', '<Leader>hp', gitsigns.preview_hunk, { desc = 'Git preview hunk' })
vim.keymap.set({ 'n', 'v' }, '<Leader>hr', gitsigns.reset_hunk, { desc = 'Git reset hunk' })

toggleterm.setup {
  open_mapping = '<Tab><CR>',
  insert_mappings = false,
  terminal_mappings = false,
  on_open = function()
    vim.keymap.set({ 'n', 't' }, '<C-[>', toggleterm.toggle, { buffer = true })
  end,
  direction = 'float',
  float_opts = { border = 'rounded' },
  highlights = {
    FloatBorder = { link = 'TelescopeBorder' },
  },
}

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
vim.keymap.set('n', '<Tab>gd', ':DiffviewOpen<CR>', { desc = 'Git diffview' })

vim.keymap.set('n', '<Tab>gs', telescope_builtins.git_status, { desc = 'Git status' })
vim.keymap.set('n', '<Tab>gb', telescope_builtins.git_branches, { desc = 'Git branches' })
vim.keymap.set('n', '<Tab>gc', telescope_builtins.git_commits, { desc = 'Git commits' })
vim.keymap.set('n', '<Tab>gf', telescope_builtins.git_bcommits, { desc = 'Git commits for current file' })
