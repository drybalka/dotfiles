local keyopts = { noremap = true, silent = true }

local lspconfig = require 'lspconfig'

-- LSP settings
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, keyopts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, keyopts)
vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, keyopts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, keyopts)
vim.keymap.set({ 'n', 'i' }, '<C-/>', vim.lsp.buf.hover, keyopts)
vim.keymap.set({ 'n', 'i' }, '<C-space>', vim.lsp.buf.signature_help, keyopts)
vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, keyopts)
vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, keyopts)
vim.keymap.set('n', '<Leader>=', vim.lsp.buf.formatting, keyopts)
vim.keymap.set('v', '<Leader>=', vim.lsp.buf.range_formatting, keyopts)
vim.keymap.set('n', '<Leader>a', vim.lsp.buf.code_action, keyopts)
vim.keymap.set('v', '<Leader>a', vim.lsp.buf.range_code_action, keyopts)

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = 'rounded',
})
require('lspconfig.ui.windows').default_options.border = 'rounded'

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.pyright.setup {
  capabilities = capabilities,
}

lspconfig.clangd.setup {
  capabilities = capabilities,
}

lspconfig.tsserver.setup {
  capabilities = capabilities,
}

lspconfig.kotlin_language_server.setup {
  capabilities = capabilities,
}

lspconfig.metals.setup {
  capabilities = capabilities,
}

lspconfig.sumneko_lua.setup {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT', -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
      },
      diagnostics = {
        globals = { 'vim' }, -- Get the language server to recognize the `vim` global
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true), -- Make the server aware of Neovim runtime files
      },
      telemetry = {
        enable = false, -- Do not send telemetry data containing a randomized but unique identifier
      },
    },
  },
}

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
vim.lsp.set_log_level 'debug'