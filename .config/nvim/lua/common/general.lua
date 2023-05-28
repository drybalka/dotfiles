local keyopts = { noremap = true, silent = true }

-- Standard options
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.ignorecase = true  -- Ignore case
vim.opt.smartcase = true   -- Do not ignore case with capitals
vim.opt.scrolloff = 4      -- Lines of context
vim.opt.softtabstop = -1   -- Set softtabstop to shiftwidth
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.splitbelow = true  -- Put new windows below current
vim.opt.splitright = true  -- Put new windows right of current
vim.opt.wrapscan = false
vim.opt.mouse = 'a'
vim.opt.showmode = false -- Do not show --INSERT-- and others on the last line
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = 'yes'
vim.opt.showtabline = 0
vim.opt.updatetime = 300
vim.opt.jumpoptions = 'view'

-- Indents
vim.opt.shiftwidth = 4
vim.api.nvim_create_autocmd('FileType', { pattern = { 'lua', 'html', 'css' }, command = 'setlocal shiftwidth=2' })

-- Do not insert comment on newline
vim.api.nvim_create_autocmd('FileType', { command = 'set formatoptions-=o' })

-- Appearance
vim.opt.termguicolors = true
vim.g.gruvbox_material_transparent_background = 1
vim.cmd [[colorscheme gruvbox-material]]
vim.cmd [[highlight! link NormalFloat Normal]]
vim.cmd [[highlight! link FloatBorder FloatermBorder]]

vim.cmd [[highlight! link DiagnosticError RedSign   ]]
vim.cmd [[highlight! link DiagnosticWarn  YellowSign]]
vim.cmd [[highlight! link DiagnosticInfo  BlueSign  ]]
vim.cmd [[highlight! link DiagnosticHint  AquaSign  ]]

-- Folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false

--Remap space as leader key
vim.keymap.set('', '<Space>', '<Nop>', keyopts)
vim.keymap.set('', '_', '<Nop>', keyopts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set line wrap options
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = 'shift:2,min:40,sbr'
vim.opt.showbreak = ' >> '

-- Allow scrolling to wraped lines with arrow keys
vim.keymap.set('', '<Up>', 'gk', keyopts)
vim.keymap.set('i', '<Up>', '<C-o>gk', keyopts)
vim.keymap.set('', '<Down>', 'gj', keyopts)
vim.keymap.set('i', '<Down>', '<C-o>gj', keyopts)

-- Exit terminal mode on escape
vim.keymap.set('t', '<C-[>', [[<C-\><C-n>]], keyopts)

-- Restore <c-i> as jump forward keymap
vim.keymap.set('n', '<c-i>', '<c-i>')

-- Diagnostics
vim.diagnostic.config { float = { border = 'rounded' } }
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, keyopts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, keyopts)

local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

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
