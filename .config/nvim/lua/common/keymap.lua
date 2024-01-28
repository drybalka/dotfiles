local clean = require 'clean'
clean.clean_keymap()
clean.clean_plugins()

vim.keymap.del({ '!', 'n', 'v', 'o' }, '<C-[>') -- escape

vim.keymap.del('!', '<C-h>') -- delete previous character
vim.keymap.del('c', '<C-w>') -- delete previous word
vim.keymap.set('i', '<C-w>', '<Cmd>normal db<Cr>') -- delete previous word using nvim-spider
vim.keymap.del('!', '<C-u>') -- delete previous text
vim.keymap.del('!', '<C-o>') -- execute single normal command
vim.keymap.del('c', '<C-b>') -- cursor to line beginning
vim.keymap.set('i', '<C-b>', '<C-o>^')
vim.keymap.del('c', '<C-e>') -- cursor to line end
vim.keymap.set('i', '<C-e>', '<C-o>$')

vim.keymap.set('!', '<C-.>', '<C-t>') -- indent line
vim.keymap.set('!', '<C-,>', '<C-d>') -- unindent line
vim.keymap.del({ 'n', 'v' }, '>') -- indent line
vim.keymap.del({ 'n', 'v' }, '<') -- unindent line

vim.keymap.set({ 'n', 'v' }, 'p', ']p') -- put and adjust indent
vim.keymap.set({ 'n', 'v' }, 'P', '[p')

vim.keymap.del({ 'n', 'v' }, '~') -- switch case

vim.keymap.del({ 'n', 'v' }, '<C-t>') -- jump to previous tag

-- :j for joining lines

vim.keymap.del({ 'n', 'v' }, '<C-a>') -- increment number
vim.keymap.del({ 'n', 'v' }, '<C-x>') -- decrement number

vim.keymap.set({ 'n', 'v' }, 'q', function()
  if vim.fn.reg_recording() == '' then
    vim.cmd 'normal! qq<Cr>'
  else
    vim.cmd 'normal! q<Cr>'
  end
end, { nowait = true }) -- record macro (only q register allowed)
vim.keymap.del({ 'n', 'v' }, 'Q') -- execute macro

vim.keymap.del('n', '.') -- repeat last change
vim.keymap.set('v', '.', 'gv') -- repeat last selection

vim.keymap.del('v', 'o') -- jump to other selection end

vim.keymap.del({ 'n', 'v', 'o' }, '{') -- jump to previous paragraph
vim.keymap.del({ 'n', 'v', 'o' }, '}') -- jump to next paragraph

vim.keymap.del({ 'n', 'v' }, '"') -- use register

-- Maybe map %, is there a matchit neovim plugin

-- Insert from registers and under cursor
vim.keymap.del('c', '<C-r>') -- insert content of a register
vim.keymap.set('i', '<C-r>', '<C-r><C-p>') -- insert content of a register
vim.keymap.del('c', '<C-r><C-w>') -- insert word under cursor
vim.keymap.del('c', '<C-r><C-a>') -- insert WORD under cursor
vim.keymap.del('c', '<C-r><C-l>') -- insert line under cursor

-- Window commands
vim.keymap.del({ 'n', 'v' }, '<C-w>')
vim.keymap.del({ 'n', 'v' }, '<C-w>h') -- jump to window
vim.keymap.del({ 'n', 'v' }, '<C-w>j')
vim.keymap.del({ 'n', 'v' }, '<C-w>k')
vim.keymap.del({ 'n', 'v' }, '<C-w>l')
vim.keymap.del({ 'n', 'v' }, '<C-w><C-h>')
vim.keymap.del({ 'n', 'v' }, '<C-w><C-j>')
vim.keymap.del({ 'n', 'v' }, '<C-w><C-k>')
vim.keymap.del({ 'n', 'v' }, '<C-w><C-l>')
vim.keymap.del({ 'n', 'v' }, '<C-w>w') -- jump to another window
vim.keymap.del({ 'n', 'v' }, '<C-w><C-w>')
vim.keymap.del({ 'n', 'v' }, '<C-w>H') -- move windows
vim.keymap.del({ 'n', 'v' }, '<C-w>J')
vim.keymap.del({ 'n', 'v' }, '<C-w>K')
vim.keymap.del({ 'n', 'v' }, '<C-w>L')
vim.keymap.del({ 'n', 'v' }, '<C-w>o') -- close all other windows
vim.keymap.del({ 'n', 'v' }, '<C-w><C-o>')
vim.keymap.set({ 'n', 'v' }, '<C-w>s', ':new<Cr>') -- split window horizontally
vim.keymap.set({ 'n', 'v' }, '<C-w>v', ':vnew<Cr>') -- split window vertically

-- Scrolling
vim.keymap.set({ 'n', 'v', 'o' }, '<C-d>', '<C-e>') -- scoll down
vim.keymap.set('i', '<C-d>', '<C-x><C-e>')
vim.keymap.set({ 'n', 'v', 'o' }, '<C-u>', '<C-y>') -- scoll up
vim.keymap.set('i', '<C-u>', '<C-x><C-y>')
vim.keymap.del({ 'n', 'v' }, 'z')
vim.keymap.del({ 'n', 'v' }, 'zt')
vim.keymap.del({ 'n', 'v' }, 'zz')
vim.keymap.del({ 'n', 'v' }, 'zb')

-- Jump to chars on the line
vim.keymap.del({ 'n', 'v', 'o' }, 'f')
vim.keymap.del({ 'n', 'v', 'o' }, 'F')
vim.keymap.del({ 'n', 'v', 'o' }, 't')
vim.keymap.del({ 'n', 'v', 'o' }, 'T')
vim.keymap.del({ 'n', 'v', 'o' }, ';') -- repeat horizontal jump
vim.keymap.del({ 'n', 'v', 'o' }, ',') -- same backwards

-- Bracket jumps
vim.keymap.del({ 'n', 'v', 'o' }, '[')
vim.keymap.del({ 'n', 'v', 'o' }, ']')
vim.keymap.del({ 'n', 'v', 'o' }, '])') -- jump to next unmatched ()
vim.keymap.del({ 'n', 'v', 'o' }, '[(')
vim.keymap.del({ 'n', 'v', 'o' }, ']}') -- jump to next unmatched {}
vim.keymap.del({ 'n', 'v', 'o' }, '[{')
vim.keymap.del({ 'n', 'v', 'o' }, ']s') -- jump to next misspelled word
vim.keymap.del({ 'n', 'v', 'o' }, '[s')

-- Marks
vim.keymap.del({ 'n', 'v' }, 'm') -- use marks
vim.keymap.del({ 'n', 'v', 'o' }, '`') -- enable mark jumps
vim.keymap.set({ 'n', 'v', 'o' }, "'", '`', { nowait = true, remap = true }) -- quote same as backward quote
vim.keymap.del({ 'n', 'v', 'o' }, '``') -- jump back
vim.keymap.del({ 'n', 'v', 'o' }, "`'")
vim.keymap.del({ 'n', 'v', 'o' }, '`"') -- jump to where last exited neovim
vim.keymap.del({ 'n', 'v', 'o' }, '`.') -- jump to last change
vim.keymap.set({ 'n', 'v', 'o' }, '`,', '`^') -- jump to last insert stop
vim.keymap.del({ 'n', 'v', 'o' }, '`<') -- jump to start of last selection
vim.keymap.del({ 'n', 'v', 'o' }, '`>') -- jump to end of last selection

-- Textobjects
vim.keymap.del({ 'v', 'o' }, 'i')
vim.keymap.del({ 'v', 'o' }, 'a')
vim.keymap.del({ 'v', 'o' }, 'iw') -- select a word
vim.keymap.del({ 'v', 'o' }, 'aw')
vim.keymap.del({ 'v', 'o' }, 'iW') -- select a WORD
vim.keymap.del({ 'v', 'o' }, 'aW')
vim.keymap.del({ 'v', 'o' }, 'ip') -- select a paragraph
vim.keymap.del({ 'v', 'o' }, 'ap')
vim.keymap.del({ 'v', 'o' }, 'ib') -- select a block
vim.keymap.del({ 'v', 'o' }, 'ab')
vim.keymap.del({ 'v', 'o' }, 'i(')
vim.keymap.del({ 'v', 'o' }, 'a(')
vim.keymap.del({ 'v', 'o' }, 'i)')
vim.keymap.del({ 'v', 'o' }, 'a)')
vim.keymap.del({ 'v', 'o' }, 'i[')
vim.keymap.del({ 'v', 'o' }, 'a[')
vim.keymap.del({ 'v', 'o' }, 'i]')
vim.keymap.del({ 'v', 'o' }, 'a]')
vim.keymap.del({ 'v', 'o' }, 'i<')
vim.keymap.del({ 'v', 'o' }, 'a<')
vim.keymap.del({ 'v', 'o' }, 'i>')
vim.keymap.del({ 'v', 'o' }, 'a>')
vim.keymap.del({ 'v', 'o' }, 'i{')
vim.keymap.del({ 'v', 'o' }, 'a{')
vim.keymap.del({ 'v', 'o' }, 'i}')
vim.keymap.del({ 'v', 'o' }, 'a}')
vim.keymap.del({ 'v', 'o' }, 'it') -- select a tag
vim.keymap.del({ 'v', 'o' }, 'at')
vim.keymap.del({ 'v', 'o' }, "i'") -- select a quote
vim.keymap.del({ 'v', 'o' }, "a'")
vim.keymap.del({ 'v', 'o' }, 'i"') -- select a double quote
vim.keymap.del({ 'v', 'o' }, 'a"')
vim.keymap.del({ 'v', 'o' }, 'i`') -- select a backward quote
vim.keymap.del({ 'v', 'o' }, 'a`')
