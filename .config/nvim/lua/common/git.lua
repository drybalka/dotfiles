local keyopts = { noremap = true, silent = true }

local gitsigns = require 'gitsigns'
local fterm = require 'FTerm'
local diffview = require 'diffview'

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

local fterm_options = {
  dimensions = {
    height = 0.9,
    width = 0.9,
  },
}
local terminal = fterm:new(fterm_options)
vim.keymap.set('n', '<Tab>tt', function()
  terminal:open()
end, keyopts)
local terminals = {}
for i = 1, 9 do
  local new_terminal = fterm:new(fterm_options)
  table.insert(terminals, new_terminal)
  vim.keymap.set('n', '<Tab>t' .. i, function()
    new_terminal:open()
  end, keyopts)
end
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'FTerm',
  callback = function()
    vim.keymap.set({ 't', 'n' }, '<C-[>', function()
      terminal:close(false)
      for _, term in ipairs(terminals) do
        term:close(false)
      end
    end, { buffer = 0 })
  end,
})

local diffview_actions = require 'diffview.actions'
diffview.setup {
  enhanced_diff_hl = true, -- See |diffview-config-enhanced_diff_hl|
  keymaps = {
    disable_defaults = true,
    view = {
      ['<C-[>'] = ':DiffviewClose<CR>',
    },
    file_panel = {
      ['j'] = diffview_actions.select_next_entry,
      ['<C-n>'] = diffview_actions.select_next_entry,
      ['k'] = diffview_actions.select_prev_entry,
      ['<C-p>'] = diffview_actions.select_prev_entry,
      ['<CR>'] = function()
        diffview_actions.goto_file_edit()
        for _, view in pairs(require('diffview.lib').views) do
          view:close()
        end
      end,
      ['<C-[>'] = ':DiffviewClose<CR>',
      ['<C-d>'] = diffview_actions.scroll_view(0.25),
      ['<C-u>'] = diffview_actions.scroll_view(-0.25),
    },
    file_history_panel = {
      ['<C-[>'] = ':DiffviewClose<CR>',
    },
  },
  hooks = {
    diff_buf_read = function()
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end,
  },
}
vim.keymap.set('n', '<Tab>gd', ':DiffviewOpen<CR>', keyopts)
