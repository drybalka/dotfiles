local keyopts = { noremap = true, silent = true }

require('dressing').setup({
  input = {
    winblend = 0,
  }
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "DressingInput",
  callback = function() vim.keymap.set('i', '<c-[>', require('dressing.input').close, { buffer = 0 }) end
})


require('Comment').setup {
  opleader = {
    line = "<leader>c",
    block = "<leader>b",
  },
  toggler = {
    line = "<leader>cc",
    block = "<leader>bc",
  },
  extra = {
    above = '<leader>cO',
    below = '<leader>co',
    eol = '<leader>cA',
  },
}


require('nvim-surround').setup()


require('indent_blankline').setup {
  filetype_exclude = { 'help' },
  buftype_exclude = { 'terminal', 'nofile' },
  use_treesitter = true,
  -- show_first_indent_level = false,
  space_char_blankline = " ",
  show_current_context = true,
  -- show_current_context_start = true,
  --char = "",
  char_list = { '|', '¦', '┆', '┊' },
}


-- Shows where the cursor moves
require('specs').setup {
  popup = {
    winhl = "Search",
    fader = require('specs').exp_fader,
    resizer = require('specs').shrink_resizer,
  }
}


-- Lualine setup
require('lualine').setup {
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
    lualine_z = { 'progress' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'progress', 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}


require("twilight").setup()

-- Toggle booleans
local function toggle()
  local toggle_table = {
    ["true"] = "false",
    ["True"] = "False",
    ["TRUE"] = "FALSE",
    ["Yes"] = "No",
    ["YES"] = "NO",
    ["1"] = "0",
    ["<"] = ">",
    ["+"] = "-"
  }
  vim.tbl_add_reverse_lookup(toggle_table)
  local function toggle_word(word)
    if toggle_table[word] ~= nil then
      return toggle_table[word]
    else
      return word
    end
  end

  local line = vim.api.nvim_get_current_line()
  local toggled_line = line:gsub('%w+', toggle_word)
  vim.api.nvim_set_current_line(toggled_line)
end

vim.keymap.set('n', '<c-s>', toggle, keyopts)
