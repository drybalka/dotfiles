local neodev = require 'neodev'
neodev.setup() -- must be run before lspconfig
local lspconfig = require 'lspconfig'
local cmp_nvim_lsp = require 'cmp_nvim_lsp'
local navbuddy = require 'nvim-navbuddy'
local lsp_format = require 'lsp-format'
local metals = require 'metals'
local refactoring = require 'refactoring'

lsp_format.setup()

local lsp_document_highlight = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = true })

local on_attach = function(client, bufnr)
  local keyopts = { noremap = true, silent = true, buffer = bufnr }
  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<Tab>d', builtin.diagnostics, keyopts)
  vim.keymap.set('n', '<Tab>s', builtin.lsp_document_symbols, keyopts)
  vim.keymap.set('n', '<Tab>S', builtin.lsp_dynamic_workspace_symbols, keyopts)
  vim.keymap.set('n', 'gr', builtin.lsp_references, keyopts)
  vim.keymap.set('n', 'gd', builtin.lsp_definitions, keyopts)
  vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, keyopts)
  vim.keymap.set('n', 'gi', builtin.lsp_implementations, keyopts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, keyopts)
  vim.keymap.set({ 'n', 'i' }, '<C-/>', vim.lsp.buf.hover, keyopts)
  vim.keymap.set({ 'n', 'i' }, '<C-space>', vim.lsp.buf.signature_help, keyopts)
  vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, keyopts)
  -- vim.keymap.set('n', '<Leader>=', vim.lsp.buf.format, keyopts)
  -- vim.keymap.set('v', '<Leader>=', 'gq', keyopts)
  vim.keymap.set('n', '<Leader>a', vim.lsp.buf.code_action, keyopts)
  -- vim.keymap.set('v', '<Leader>a', vim.lsp.buf.range_code_action, keyopts)
  vim.keymap.set('n', '<Leader>s', navbuddy.open, keyopts)

  lsp_format.on_attach(client)

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

local jump_to_location = vim.lsp.util.jump_to_location
vim.lsp.util.jump_to_location = function(location, offset_encoding, reuse_win)
  jump_to_location(location, offset_encoding, reuse_win)
  vim.cmd 'normal zt'
end

local standard_servers = {
  'pylsp',
  'clangd',
  'tsserver',
  -- 'metals',
  'rust_analyzer',
  'html',
  'cssls',
  'jsonls',
  'lua_ls',
  -- 'stylelint-lsp',
  -- 'ruff-lsp',
  -- 'eslint?',
  -- 'prettier?',
}

-- nvim-cmp supports additional completion capabilities
local capabilities = cmp_nvim_lsp.default_capabilities()
for _, server in ipairs(standard_servers) do
  lspconfig[server].setup {
    capabilities = capabilities,
    on_attach = on_attach,
  }
end

local metals_config = metals.bare_config()
metals_config.settings = {
  showImplicitArguments = true,
  showImplicitConversionsAndClasses = true,
  showInferredType = true,
  superMethodLensesEnabled = false,
  excludedPackages = { 'akka.actor.typed.javadsl', 'com.github.swagger.akka.javadsl' },
  serverProperties = { '-Xmx3g' },
  serverVersion = 'latest.snapshot',
}
metals_config.capabilities = capabilities
metals_config.on_attach = function(client, bufnr)
  on_attach(client, bufnr)
  vim.keymap.set('n', '<Tab>i', require('telescope').extensions.metals.commands, { desc = 'Metals commands' })
  metals.setup_dap()
end
local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'scala', 'sbt' },
  callback = function()
    metals.initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group,
})

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

refactoring.setup {}
vim.keymap.set({ 'n', 'x' }, '<leader>rf', function()
  refactoring.select_refactor {}
end)

-- vim.lsp.set_log_level 'debug'
