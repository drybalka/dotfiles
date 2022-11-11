local keyopts = { noremap = true, silent = true }

local lspkind = require 'lspkind'
local luasnip = require 'luasnip'
local null_ls = require 'null-ls'
local cmp = require 'cmp'
if not cmp then
  return
end

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
  mapping = cmp.mapping.preset.insert {
    ['<C-u>'] = { i = cmp.mapping.scroll_docs(-4) },
    ['<C-d>'] = { i = cmp.mapping.scroll_docs(4) },
    ['<C-M-Space>'] = { i = cmp.mapping.complete {} },
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
  ---@diagnostic disable-next-line: assign-type-mismatch
  completion = { autocomplete = false },
  mapping = {
    ['<C-n>'] = {
      c = cmp.mapping.select_next_item { behavior = require('cmp.types').cmp.SelectBehavior.Insert },
    },
    ['<C-p>'] = {
      c = cmp.mapping.select_prev_item { behavior = require('cmp.types').cmp.SelectBehavior.Insert },
    },
    ['<C-M-Space>'] = { c = cmp.mapping.complete {} },
    ['<C-y>'] = { c = cmp.mapping.confirm { select = true } },
    ['<C-e>'] = { c = cmp.mapping.abort() },
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
end, keyopts)
vim.keymap.set({ 'i', 's' }, '<C-k>', function()
  luasnip.jump(-1)
end, keyopts)

null_ls.setup {
  sources = {
    null_ls.builtins.code_actions.eslint_d,
    null_ls.builtins.diagnostics.eslint_d,

    null_ls.builtins.diagnostics.stylelint.with {
      extra_args = { '--config', '/usr/lib/node_modules/stylelint-config-standard/index.js' },
    },
    null_ls.builtins.formatting.stylelint.with {
      extra_args = { '--config', '/usr/lib/node_modules/stylelint-config-standard/index.js' },
    },

    null_ls.builtins.code_actions.refactoring,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.cfn_lint,
  },
}