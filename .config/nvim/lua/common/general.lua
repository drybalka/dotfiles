local neodev = require 'neodev'

-- Standard options
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.ignorecase = true -- Ignore case
vim.o.smartcase = true -- Do not ignore case with capitals
vim.o.scrolloff = 4 -- Lines of context
vim.o.softtabstop = -1 -- Set softtabstop to shiftwidth
vim.o.smartindent = true -- Insert indents automatically
vim.o.shiftwidth = 2
vim.o.splitbelow = true -- Put new windows below current
vim.o.splitright = true -- Put new windows right of current
vim.o.wrapscan = false
vim.o.mouse = 'a'
vim.o.showmode = false -- Do not show --INSERT-- and others on the last line
vim.o.number = false
vim.o.relativenumber = false
vim.o.signcolumn = 'yes'
vim.o.showtabline = 0
vim.o.updatetime = 300
vim.o.jumpoptions = 'view'
vim.o.spell = true
vim.o.digraph = false

vim.g.markdown_recommended_style = 0

-- Do not insert comment on newline
vim.api.nvim_create_autocmd('FileType', { command = 'set formatoptions-=o' })

-- Appearance
vim.o.termguicolors = true
vim.g.gruvbox_material_transparent_background = 1
vim.cmd [[colorscheme gruvbox-material]]
vim.cmd [[highlight! link NormalFloat Normal]]
vim.cmd [[highlight! link FloatBorder TelescopeBorder]]
vim.cmd [[highlight! link FloatTitle  TelescopeTitle]]

vim.cmd [[highlight! link DiagnosticError RedSign   ]]
vim.cmd [[highlight! link DiagnosticWarn  YellowSign]]
vim.cmd [[highlight! link DiagnosticInfo  BlueSign  ]]
vim.cmd [[highlight! link DiagnosticHint  AquaSign  ]]

-- Folding
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldenable = false

--Remap space as leader key
vim.keymap.set('', '<Space>', '<Nop>')
vim.keymap.set('', '_', '<Nop>')
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set line wrap options
vim.o.linebreak = true
vim.o.breakindent = true
vim.o.breakindentopt = 'shift:2,min:40,sbr'
vim.o.showbreak = ' >> '

-- Allow scrolling to wrapped lines with arrow keys
vim.keymap.set('', '<Up>', 'gk')
vim.keymap.set('i', '<Up>', '<C-o>gk')
vim.keymap.set('', '<Down>', 'gj')
vim.keymap.set('i', '<Down>', '<C-o>gj')

-- Exit terminal mode on escape
-- vim.keymap.set('t', '<C-[>', [[<C-\><C-n>]])

-- Restore <C-i> as jump forward keymap
vim.keymap.set('n', '<C-i>', '<C-i>')

-- Diagnostics
vim.diagnostic.config { float = { border = 'rounded' } }
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Diagnostics prev' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Diagnostics next' })

local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

neodev.setup {
  library = { plugins = { 'neotest' }, types = true },
}

function P(v)
  local function dump(o, level)
    local tab = '    '
    if not level then
      level = 0
    end
    if type(o) == 'table' then
      local shift = string.rep(tab, level)
      local s = '{\n'
      for k, v in pairs(o) do
        if type(k) ~= 'number' then
          k = '"' .. tostring(k) .. '"'
        end
        s = s .. shift .. tab .. '[' .. k .. '] = ' .. dump(v, level + 1) .. ',\n'
      end
      return s .. shift .. '}\n' .. shift
    else
      return tostring(o)
    end
  end

  print(dump(v))
  return dump(v)
end

function R(name)
  require('plenary.reload').reload_module(name)
  return require(name)
end
