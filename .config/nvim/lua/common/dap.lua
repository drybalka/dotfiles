local dap = require 'dap'
local stackmap = require 'stackmap'
local dapui = require 'dapui'

dapui.setup {
  controls = { enabled = false },
  floating = { border = 'rounded', max_height = 0.9, max_width = 0.9 },
}

vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'Red', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'Red', linehl = '', numhl = '' })

vim.keymap.set('n', '<Leader>db', dap.toggle_breakpoint, { desc = 'dap breakpoint' })
vim.keymap.set('n', '<Leader>dr', dap.continue, { desc = 'dap run' })
vim.keymap.set('n', '<Leader>dc', dap.repl.toggle, { desc = 'dap console' })
vim.keymap.set('n', '<Leader>dt', dap.terminate, { desc = 'dap terminate' })
vim.keymap.set({ 'n', 'v' }, '<Leader>de', require('dapui').eval, { desc = 'dap eval' })
vim.keymap.set('n', '<Leader>dd', function()
  dapui.float_element(nil, { enter = true })
end, { desc = 'dap elements' })

local is_debugging = false
dap.listeners.after.event_initialized['dapui_config'] = function()
  is_debugging = true
  stackmap.push('Dap', 'n', {
    ['<C-j>'] = dap.step_over,
    ['<C-l>'] = dap.step_into,
    ['<C-h>'] = dap.step_out,
    ['<C-k>'] = dap.step_back,
  })
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  if is_debugging then
    is_debugging = false
    stackmap.pop('Dap', 'n')
  end
end
dap.listeners.before.event_exited['dapui_config'] = function()
  if is_debugging then
    is_debugging = false
    stackmap.pop('Dap', 'n')
  end
end

require('dap-python').setup()

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
