local dap = require 'dap'
local dapui = require 'dapui'
local python = require 'dap-python'

dapui.setup {
  controls = { enabled = false },
  floating = { border = 'rounded', max_height = 0.9, max_width = 0.9 },
}

vim.fn.sign_define('DapBreakpoint', { text = ' ', texthl = 'Red', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = ' ', texthl = 'Red', linehl = '', numhl = '' })

vim.keymap.set('n', '<Leader>db', dap.toggle_breakpoint, { desc = 'DAP set breakpoint' })
vim.keymap.set('n', '<Leader>dr', dap.continue, { desc = 'DAP run/continue' })
vim.keymap.set('n', '<Leader>ds', dap.terminate, { desc = 'DAP stop' })
vim.keymap.set({ 'n', 'v' }, '<Leader>de', dapui.eval, { desc = 'DAP evaluate expression' })
vim.keymap.set('n', '<Leader>dd', function()
  dapui.float_element(nil, { enter = true })
end, { desc = 'DAP open element' })

python.setup()

dap.configurations.scala = {
  {
    type = 'scala',
    request = 'launch',
    name = 'RunOrTest',
    metals = {
      runType = 'runOrTestFile',
      --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
    },
  },
  {
    type = 'scala',
    request = 'launch',
    name = 'Test Target',
    metals = {
      runType = 'testTarget',
    },
  },
}

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
