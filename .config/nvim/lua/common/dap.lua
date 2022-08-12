local dap = require "dap"

local keyopts = { noremap = true, silent = true }
vim.keymap.set("n", "<F1>", require("dap").step_back, keyopts)
vim.keymap.set("n", "<F2>", require("dap").step_into, keyopts)
vim.keymap.set("n", "<F3>", require("dap").step_over, keyopts)
vim.keymap.set("n", "<F4>", require("dap").step_out, keyopts)
vim.keymap.set("n", "<F5>", require("dap").continue, keyopts)
vim.keymap.set("n", "<F6>", require("dap").toggle_breakpoint, keyopts)

-- vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})


dap.configurations.lua = {
  {
    type = 'nlua',
    request = 'attach',
    name = "Attach to running Neovim instance",
    host = function()
      local value = vim.fn.input('Host [127.0.0.1]: ')
      if value ~= "" then
        return value
      end
      return '127.0.0.1'
    end,
    port = function()
      local val = tonumber(vim.fn.input('Port: '))
      assert(val, "Please provide a port number")
      return val
    end,
  }
}
dap.adapters.nlua = function(callback, config)
  callback({ type = 'server', host = config.host, port = config.port })
end

