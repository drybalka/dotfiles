local dressing = require 'dressing'
local comment = require 'Comment'
local surround = require 'nvim-surround'
local indent_blankline = require 'ibl'
local specs = require 'specs'
local lualine = require 'lualine'
local twilight = require 'twilight'
local dap = require 'dap'
local spider = require 'spider'
local auto_hlsearch = require 'auto-hlsearch'

auto_hlsearch.setup()

vim.keymap.set('n', 'gx', '<cmd>silent !firefox <cfile><CR>')

dressing.setup {
  input = {
    win_options = {
      winblend = 0,
    },
  },
}
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'DressingInput',
  callback = function()
    vim.keymap.set('i', '<C-[>', require('dressing.input').close, { buffer = 0 })
  end,
})

comment.setup {
  opleader = {
    line = '<Leader>c',
    block = '<Leader>b',
  },
  toggler = {
    line = '<Leader>cc',
    block = '<Leader>bc',
  },
  extra = {
    above = '<Leader>cO',
    below = '<Leader>co',
    eol = '<Leader>cA',
  },
}

surround.setup()

indent_blankline.setup {
  indent = {
    char = { '|', '¦', '┆', '┊' },
  },
  scope = {
    show_start = false,
    show_end = false,
  },
  exclude = {
    filetypes = { 'markdown' },
  },
}

-- Shows where the cursor moves
specs.setup {
  popup = {
    winhl = 'Search',
    fader = specs.exp_fader,
    resizer = specs.shrink_resizer,
  },
}

local function dap_controls()
  local controls = {
    { icon = '', func = 'continue', color = 'Green' },
    { icon = '', func = 'run_last', color = 'Green' },
    { icon = '', func = 'step_into', color = 'Blue' },
    { icon = '', func = 'step_over', color = 'Blue' },
    { icon = '', func = 'step_out', color = 'Blue' },
    { icon = '', func = 'step_back', color = 'Blue' },
    { icon = '', func = 'terminate', color = 'Red' },
  }
  local res = { dap.status }
  for _, elem in ipairs(controls) do
    table.insert(res, {
      function()
        return elem.icon
      end,
      cond = function()
        return dap.session() ~= nil
      end,
      color = { fg = string.format('#%06x', vim.api.nvim_get_hl(0, {})[elem.color].fg) },
      on_click = function()
        dap[elem.func]()
      end,
    })
  end
  return res
end

-- Lualine setup
lualine.setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { 'location' },
    lualine_b = { 'diagnostics', 'diff' },
    lualine_c = { { 'filetype', icon_only = true, separator = '' }, { 'filename', path = 1 } },
    lualine_x = dap_controls(),
    lualine_y = {},
    lualine_z = { 'progress' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'progress', 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
}

twilight.setup()

-- Toggle booleans
local function toggle()
  local toggle_table = {
    ['true'] = 'false',
    ['True'] = 'False',
    ['TRUE'] = 'FALSE',
    ['Yes'] = 'No',
    ['YES'] = 'NO',
    ['1'] = '0',
    ['<'] = '>',
    ['+'] = '-',
  }
  vim.tbl_add_reverse_lookup(toggle_table)
  local num_of_changes = 1
  local function toggle_word(word)
    if toggle_table[word] ~= nil and num_of_changes ~= 0 then
      num_of_changes = num_of_changes - 1
      return toggle_table[word]
    end
  end

  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)[2]
  local split_point = line:sub(0, cursor + 1):find '[a-zA-Z]*$'
  local line_start = line:sub(0, split_point - 2)
  local line_end = line:sub(split_point - 1)
  -- P(line_start..'|'..line_end)
  local toggled_line = line_end:gsub('[a-zA-Z0-9-+<>]+', toggle_word)
  vim.api.nvim_set_current_line(line_start .. toggled_line)
end

-- Scratch buffer
local scratch_buffer
local function open_scratch_buffer()
  if not scratch_buffer then
    scratch_buffer = vim.api.nvim_create_buf(false, true)
    vim.keymap.set('n', '<C-[>', function()
      vim.api.nvim_win_close(0, false)
    end, { buffer = scratch_buffer })
  end
  if vim.fn.bufnr() ~= scratch_buffer then
    vim.api.nvim_open_win(scratch_buffer, true, {
      relative = 'win',
      row = 2,
      col = 4,
      width = vim.api.nvim_win_get_width(0) - 10,
      height = vim.api.nvim_win_get_height(0) - 4,
      border = 'rounded',
      title = ' Scratch buffer ',
      title_pos = 'center',
    })
  end
end

local saved_views = {}
vim.api.nvim_create_autocmd('BufLeave', {
  callback = function()
    saved_views[vim.api.nvim_get_current_buf()] = vim.fn.winsaveview()
  end,
})
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    if saved_views[bufnr] then
      vim.fn.winrestview(saved_views[bufnr])
    end
  end,
})

vim.keymap.set('n', '<Tab>y', open_scratch_buffer, { desc = 'Scratch buffer open' })
vim.keymap.set('n', '<C-s>', toggle, { desc = 'Toggle boolean' })
vim.keymap.set({ 'n', 'o', 'x' }, 'w', function()
  spider.motion 'w'
end, { desc = 'Spider-w' })
vim.keymap.set({ 'n', 'o', 'x' }, 'e', function()
  spider.motion 'e'
end, { desc = 'Spider-e' })
vim.keymap.set({ 'n', 'o', 'x' }, 'b', function()
  spider.motion 'b'
end, { desc = 'Spider-b' })
vim.keymap.set({ 'n', 'o', 'x' }, 'ge', function()
  spider.motion 'ge'
end, { desc = 'Spider-ge' })
