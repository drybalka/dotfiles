local keyopts = { noremap = true, silent = true }

-- LSP settings
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, keyopts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, keyopts)
vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, keyopts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, keyopts)
vim.keymap.set({ 'n', 'i' }, '<c-/>', vim.lsp.buf.hover, keyopts)
vim.keymap.set({ 'n', 'i' }, '<c-space>', vim.lsp.buf.signature_help, keyopts)
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, keyopts)
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, keyopts)
vim.keymap.set('n', '<leader>=', vim.lsp.buf.formatting, keyopts)
vim.keymap.set('v', '<leader>=', vim.lsp.buf.range_formatting, keyopts)
vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, keyopts)
vim.keymap.set('v', '<leader>a', vim.lsp.buf.range_code_action, keyopts)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded"
})
require('lspconfig.ui.windows').default_options.border = 'rounded'

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

require('lspconfig').pyright.setup {
  capabilities = capabilities,
}

require('lspconfig').clangd.setup {
  capabilities = capabilities,
}

require('lspconfig').tsserver.setup {
  capabilities = capabilities,
}

require('lspconfig').kotlin_language_server.setup {
  capabilities = capabilities,
}

require('lspconfig').metals.setup {
  capabilities = capabilities,
}

require 'lspconfig'.sumneko_lua.setup {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT', -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
      },
      diagnostics = {
        globals = { 'vim' }, -- Get the language server to recognize the `vim` global
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true), -- Make the server aware of Neovim runtime files
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
-- require('lspconfig').denols.setup {
--   init_options = {
--     lint = true,
--   },
-- }

require('lspconfig').jdtls.setup {
  capabilities = capabilities,
  on_new_config = function(new_config, new_root_dir)
    local conf = vim.loop.os_homedir() .. "/.cache/jdtls"
    local data = new_root_dir:gsub("(.*)/(%w+)", conf .. "/workspaces/%1/%2")
    new_config.cmd = {
      "jdtls-with-latest-jvm",
      "-configuration", conf,
      "-data", data,
    }
  end,
}
vim.lsp.set_log_level("debug")
