local keyopts = { noremap = true, silent = true }

local dressing = require 'dressing'
local comment = require 'Comment'
local surround = require 'nvim-surround'
local indent_blankline = require 'indent_blankline'
local specs = require 'specs'
local lualine = require 'lualine'
local twilight = require 'twilight'

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
  filetype_exclude = { 'help' },
  buftype_exclude = { 'terminal', 'nofile' },
  use_treesitter = true,
  -- show_first_indent_level = false,
  space_char_blankline = ' ',
  show_current_context = true,
  -- show_current_context_start = true,
  --char = "",
  char_list = { '|', '¦', '┆', '┊' },
}

-- Shows where the cursor moves
specs.setup {
  popup = {
    winhl = 'Search',
    fader = specs.exp_fader,
    resizer = specs.shrink_resizer,
  },
}

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
    lualine_x = { 'tabs' },
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

vim.keymap.set('n', '<C-s>', toggle, keyopts)
