local keyopts = { noremap = true, silent = true }

local dap = require 'dap'

vim.keymap.set('n', '<F1>', dap.step_back, keyopts)
vim.keymap.set('n', '<F2>', dap.step_into, keyopts)
vim.keymap.set('n', '<F3>', dap.step_over, keyopts)
vim.keymap.set('n', '<F4>', dap.step_out, keyopts)
vim.keymap.set('n', '<F5>', dap.continue, keyopts)
vim.keymap.set('n', '<F6>', dap.toggle_breakpoint, keyopts)

-- vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})

dap.configurations.lua = {
  {
    type = 'nlua',
    request = 'attach',
    name = 'Attach to running Neovim instance',
    host = function()
      local value = vim.fn.input 'Host [127.0.0.1]: '
      if value ~= '' then
        return value
      end
      return '127.0.0.1'
    end,
    port = function()
      local val = tonumber(vim.fn.input 'Port: ')
      assert(val, 'Please provide a port number')
      return val
    end,
  },
}
dap.adapters.nlua = function(callback, config)
  callback { type = 'server', host = config.host, port = config.port }
end
