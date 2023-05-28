require('neodev').setup()
local lspconfig = require 'lspconfig'
local null_ls = require 'null-ls'
local navbuddy = require 'nvim-navbuddy'
local lsp_format = require 'lsp-format'

lsp_format.setup()

local lsp_document_highlight = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = true })

-- scroll cursor to the top on jumps
local jump_and_scroll = function(jumper)
  return function()
    local name = vim.api.nvim_buf_get_name(0)
    local cursor = vim.api.nvim_win_get_cursor(0)

    jumper()

    local wait_result = vim.wait(1000, function()
      local new_name = vim.api.nvim_buf_get_name(0)
      local new_cursor = vim.api.nvim_win_get_cursor(0)
      return new_name ~= name or new_cursor[1] ~= cursor[1] or new_cursor[2] ~= cursor[2]
    end, 10)

    if wait_result then
      vim.cmd 'normal zt'
    end
  end
end

local on_attach = function(client, bufnr)
  local keyopts = { noremap = true, silent = true, buffer = bufnr }
  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<Tab>p', builtin.diagnostics, keyopts)
  vim.keymap.set('n', '<Tab>s', builtin.lsp_document_symbols, keyopts)
  vim.keymap.set('n', '<Tab>r', builtin.lsp_references, keyopts)
  vim.keymap.set('n', 'gd', jump_and_scroll(builtin.lsp_definitions), keyopts)
  vim.keymap.set('n', 'gt', jump_and_scroll(builtin.lsp_type_definitions), keyopts)
  vim.keymap.set('n', 'gi', jump_and_scroll(builtin.lsp_implementations), keyopts)
  vim.keymap.set('n', 'gD', jump_and_scroll(vim.lsp.buf.declaration), keyopts)
  vim.keymap.set({ 'n', 'i' }, '<C-/>', vim.lsp.buf.hover, keyopts)
  vim.keymap.set({ 'n', 'i' }, '<C-space>', vim.lsp.buf.signature_help, keyopts)
  vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, keyopts)
  vim.keymap.set('n', '<Leader>=', vim.lsp.buf.format, keyopts)
  vim.keymap.set('v', '<Leader>=', 'gq', keyopts)
  vim.keymap.set('n', '<Leader>a', vim.lsp.buf.code_action, keyopts)
  -- vim.keymap.set('v', '<Leader>a', vim.lsp.buf.range_code_action, keyopts)
  vim.keymap.set('n', '<Leader>s', navbuddy.open, keyopts)

  require('lsp-format').on_attach(client)

  if client.server_capabilities.documentSymbolProvider then
    navbuddy.attach(client, bufnr)
  end

  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_clear_autocmds { group = lsp_document_highlight, buffer = bufnr }
    vim.api.nvim_create_autocmd('CursorHold', {
      callback = vim.lsp.buf.document_highlight,
      group = lsp_document_highlight,
      buffer = bufnr,
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
      callback = vim.lsp.buf.clear_references,
      group = lsp_document_highlight,
      buffer = bufnr,
    })
  end
end

navbuddy.setup {
  window = {
    size = '90%',
    sections = {
      left = {
        size = '15%',
      },
      mid = {
        size = '25%',
      },
    },
  },
  source_buffer = {
    highlight = false,
  },
}

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = 'rounded',
})
require('lspconfig.ui.windows').default_options.border = 'rounded'

local standard_servers = {
  'pylsp',
  'clangd',
  'tsserver',
  'kotlin_language_server',
  'metals',
  'rust_analyzer',
  'html',
  'cssls',
  'jsonls',
  'lua_ls',
}

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()
for _, server in ipairs(standard_servers) do
  lspconfig[server].setup {
    capabilities = capabilities,
    on_attach = on_attach,
  }
end

-- vim.g.markdown_fenced_languages = {
--   "ts=typescript"
-- }
-- lspconfig.denols.setup {
--   init_options = {
--     lint = true,
--   },
-- }

lspconfig.jdtls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  on_new_config = function(new_config, new_root_dir)
    local conf = vim.loop.os_homedir() .. '/.cache/jdtls'
    local data = new_root_dir:gsub('(.*)/(%w+)', conf .. '/workspaces/%1/%2')
    new_config.cmd = {
      'jdtls-with-latest-jvm',
      '-configuration',
      conf,
      '-data',
      data,
    }
  end,
}

null_ls.setup {
  -- debug = true,
  border = 'rounded',
  on_attach = on_attach,
  sources = {
    null_ls.builtins.code_actions.eslint_d,
    null_ls.builtins.diagnostics.eslint_d,

    null_ls.builtins.diagnostics.stylelint.with {
      filetypes = { 'css' },
      extra_args = { '--config', '/usr/lib/node_modules/stylelint-config-standard/index.js' },
    },
    null_ls.builtins.formatting.stylelint.with {
      filetypes = { 'css' },
      extra_args = { '--config', '/usr/lib/node_modules/stylelint-config-standard/index.js' },
    },

    null_ls.builtins.formatting.yapf,
    null_ls.builtins.diagnostics.ruff,

    null_ls.builtins.code_actions.refactoring,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.cfn_lint,
  },
}
-- vim.lsp.set_log_level 'debug'
