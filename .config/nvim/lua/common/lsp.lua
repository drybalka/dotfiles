local lspconfig = require 'lspconfig'
local cmp_nvim_lsp = require 'cmp_nvim_lsp'
local navbuddy = require 'nvim-navbuddy'
local metals = require 'metals'
local refactoring = require 'refactoring'
local conform = require 'conform'

local lsp_document_highlight = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = true })

local on_attach = function(client, bufnr)
  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<Tab>d', builtin.diagnostics, { buffer = bufnr, desc = 'Telescope diagnostics' })
  vim.keymap.set('n', '<Tab>s', builtin.lsp_document_symbols, { buffer = bufnr, desc = 'Telescope file symbols' })
  vim.keymap.set(
    'n',
    '<Tab>S',
    builtin.lsp_dynamic_workspace_symbols,
    { buffer = bufnr, desc = 'Telescope workspace lsp' }
  )
  vim.keymap.set('n', 'gr', builtin.lsp_references, { buffer = bufnr, desc = 'LSP goto references' })
  vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = bufnr, desc = 'LSP goto defnition' })
  vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, { buffer = bufnr, desc = 'LSP goto type definition' })
  vim.keymap.set('n', 'gi', builtin.lsp_implementations, { buffer = bufnr, desc = 'LSP goto implementation' })
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = bufnr, desc = 'LSP goto declaration' })
  vim.keymap.set({ 'n', 'i' }, '<C-/>', vim.lsp.buf.hover, { buffer = bufnr, desc = 'LSP hover' })
  vim.keymap.set({ 'n', 'i' }, '<C-space>', vim.lsp.buf.signature_help, { buffer = bufnr, desc = 'LSP signature help' })
  vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, { buffer = bufnr, desc = 'LSP rename' })
  vim.keymap.set({ 'n', 'x' }, '<leader>rf', refactoring.select_refactor, { buffer = bufnr, desc = 'LSP refactor' })
  vim.keymap.set('n', '<Leader>a', vim.lsp.buf.code_action, { buffer = bufnr, desc = 'LSP code action' })
  vim.keymap.set('n', '<Leader>s', navbuddy.open, { buffer = bufnr, desc = 'LSP navbuddy' })
  -- vim.keymap.set('v', '<Leader>a', vim.lsp.buf.range_code_action, { buffer = bufnr, desc = '' })
  -- vim.keymap.set('n', '<Leader>=', vim.lsp.buf.format, { buffer = bufnr, desc = '' })
  -- vim.keymap.set('v', '<Leader>=', 'gq', { buffer = bufnr, desc = '' })

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
  'pylsp', -- 'python-lsp-ruff', 'python-lsp-black'?
  'clangd',
  'tsserver',
  'rust_analyzer',
  'html',
  'cssls',
  'jsonls',
  'lua_ls',
  -- 'stylelint-lsp',
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
  superMethodLensesEnabled = true,
  excludedPackages = { 'akka.actor.typed.javadsl', 'com.github.swagger.akka.javadsl' },
  serverProperties = { '-Xmx3g' },
  serverVersion = 'latest.snapshot',
  testUserInterface = 'Test Explorer', -- disables virtual text for tests
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

conform.setup {
  formatters_by_ft = {
    lua = { 'stylua' },
  },
  format_on_save = {
    lsp_fallback = true,
    timeout_ms = 500,
  },
}

-- vim.lsp.set_log_level 'debug'
