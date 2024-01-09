local api_key = os.getenv 'OPENAI_API_KEY'
local chat_url = os.getenv 'OPENAI_CHAT_URL'
local info_url = os.getenv 'OPENAI_INFO_URL'
local model_num = 1
local models

local separator = '---------------------------------------'
local chat_prompt =
  'You are an AI programming assistant. Follow the users requirements carefully and to the letter. First, think step-by-step and describe your plan for what to build in pseudocode, written out in great detail. Then, output the code in a single code block. Minimize any other prose.'
local chat_buffer
local chat_win
local chat_process

local log_path = vim.fn.stdpath 'log' .. '/openai.log'
local log_file
local log = function(message)
  if log_file then
    vim.loop.fs_write(log_file, message .. '\n')
  end
end

local curl = function(args, stream_handler, exit_handler)
  if type(args) == 'function' then
    args = args()
  end

  local stdout = vim.loop.new_pipe()
  log_file = vim.loop.fs_open(log_path, 'a', 0x1A4)

  chat_process = vim.loop.spawn(
    'curl',
    {
      args = args,
      stdio = { nil, stdout, nil },
    },
    vim.schedule_wrap(function()
      stdout:read_stop()
      stdout:close()
      if log_file then
        vim.loop.fs_close(log_file)
        log_file = nil
      end
      if chat_process and not chat_process:is_closing() then
        chat_process:close()
        chat_process = nil
      end
      if exit_handler then
        exit_handler()
      end
    end)
  )

  stdout:read_start(vim.schedule_wrap(function(err, chunk)
    if err then
      log(err)
    elseif chunk then
      log(chunk)
      if stream_handler then
        stream_handler(chunk)
      end
    end
  end))
end

local info_args = {
  info_url,
  '--silent',
  '-H',
  'Authorization: Bearer ' .. api_key,
}

local update_chat_window_title = function()
  vim.api.nvim_win_set_config(chat_win, {
    title = ' ' .. models[model_num]['name'] .. ' ',
    title_pos = 'center',
  })
end

---@param data string
local info_stream_handler = function(data)
  models = vim.json.decode(data)['models']
  update_chat_window_title()
end

---@param data string
local chat_stream_handler = function(data)
  local content = data:match '"content": "(.-)"}'
  if content then
    log(content)
    content = content:gsub('<', '<LT>'):gsub('\\n', '\r'):gsub('\\t', '\t'):gsub('\\"', '"')
    log(content)
    vim.api.nvim_input(content)
  end
end

local chat_exit_handler = function()
  vim.cmd 'stopinsert'
  vim.api.nvim_buf_set_lines(chat_buffer, -1, -1, true, { '', separator, '' })
  vim.api.nvim_input 'G'
end

local chat_to_messages = function()
  local chat = vim.api.nvim_buf_get_lines(chat_buffer, 0, -1, true)
  local contents = { '' }
  for _, line in ipairs(chat) do
    if line:match(separator) then
      contents[#contents + 1] = ''
    else
      contents[#contents] = contents[#contents] .. line .. '\n'
    end
  end
  local messages = {}
  for i, content in ipairs(contents) do
    content = content:match '^%s*(.-)%s*$'
    if i % 2 == 0 then
      messages[i] = { role = 'user', content = content }
    else
      messages[i] = { role = 'assistant', content = content }
    end
  end
  messages[1].role = 'system'
  return messages
end

local chat_args = function()
  return {
    chat_url,
    '-X',
    'POST',
    '--no-buffer',
    '--silent',
    '-H',
    'Content-Type: application/json',
    '-H',
    'Authorization: Bearer ' .. api_key,
    '-d',
    vim.json.encode { messages = chat_to_messages(), model = models[model_num]['name'], stream = true },
  }
end

local open_chat_buffer = function()
  if not chat_buffer then
    os.remove(log_path)
    chat_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(chat_buffer, 'filetype', 'markdown')
    vim.api.nvim_buf_set_lines(chat_buffer, 0, 0, true, { '', chat_prompt, '', separator })
    curl(info_args, info_stream_handler)
    vim.api.nvim_input 'G'
    vim.keymap.set('i', '<C-[>', function()
      if chat_process then
        chat_process:kill(15)
      else
        vim.cmd 'stopinsert'
      end
    end, { buffer = chat_buffer })
    vim.keymap.set('n', '<C-[>', function()
      vim.api.nvim_win_close(0, false)
    end, { buffer = chat_buffer })
    vim.keymap.set('n', '<C-n>', function()
      if model_num == #models then
        model_num = 1
      else
        model_num = model_num + 1
      end
      update_chat_window_title()
    end, { buffer = chat_buffer })
    vim.keymap.set('n', '<C-p>', function()
      if model_num == 1 then
        model_num = #models
      else
        model_num = model_num - 1
      end
      update_chat_window_title()
    end, { buffer = chat_buffer })
    vim.keymap.set({ 'n', 'i' }, '<C-CR>', function()
      vim.cmd 'stopinsert'
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(chat_buffer, -1, -1, true, { '', separator .. ' ' .. models[model_num]['name'], '' })
        vim.api.nvim_input 'Go'
        curl(chat_args, chat_stream_handler, chat_exit_handler)
      end)
    end, { buffer = chat_buffer })
  end
  if vim.fn.bufnr() ~= chat_buffer then
    chat_win = vim.api.nvim_open_win(chat_buffer, true, {
      relative = 'win',
      row = 2,
      col = 4,
      width = vim.api.nvim_win_get_width(0) - 10,
      height = vim.api.nvim_win_get_height(0) - 4,
      border = 'rounded',
      title = ' Loading available models... ',
      title_pos = 'center',
    })
  end
end
vim.keymap.set('n', '<Tab>c', open_chat_buffer, { desc = 'OpenAi chat open' })
