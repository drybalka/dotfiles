local lspkind = require 'lspkind'
local luasnip = require 'luasnip'
local cmp = require 'cmp'

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  view = {
    entries = { name = 'custom', selection_order = 'near_cursor' },
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  }, {
    { name = 'buffer', option = { get_bufnrs = vim.api.nvim_list_bufs } },
  }),
  mapping = {
    ['<C-n>'] = { i = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert } },
    ['<C-p>'] = { i = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert } },
    ['<C-u>'] = { i = cmp.mapping.scroll_docs(-1) },
    ['<C-d>'] = { i = cmp.mapping.scroll_docs(1) },
    ['<C-y>'] = { i = cmp.mapping.confirm { select = true } },
  },
  experimental = {
    ghost_text = true,
  },
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = '[buf]',
        nvim_lsp = '[lsp]',
        path = '[path]',
        luasnip = '[snip]',
      },
    },
  },
}

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline {
    ['<C-y>'] = { c = cmp.mapping.confirm { select = true } },
  },
  sources = {
    { name = 'buffer' },
  },
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline {
    ['<C-y>'] = { c = cmp.mapping.confirm { select = true } },
  },
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})

require('luasnip/loaders/from_vscode').lazy_load()

vim.keymap.set({ 'i', 's' }, '<C-j>', function()
  luasnip.jump(1)
end)
vim.keymap.set({ 'i', 's' }, '<C-k>', function()
  luasnip.jump(-1)
end)
