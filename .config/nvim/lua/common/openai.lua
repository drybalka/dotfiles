local api_key = os.getenv 'OPENAI_API_KEY'
local chat_url = os.getenv 'OPENAI_CHAT_URL'
local info_url = os.getenv 'OPENAI_INFO_URL'

local model_num = 1
local models

local log_path = vim.fn.stdpath 'log' .. '/openai.log'
local log_file
local log = function(message)
  if log_file then
    vim.loop.fs_write(log_file, message .. '\n')
  end
end

local curl_process
local curl = function(args, stream_handler, exit_handler)
  if type(args) == 'function' then
    args = args()
  end

  local stdout = vim.loop.new_pipe()
  log_file = vim.loop.fs_open(log_path, 'a', 0x1A4)

  curl_process = vim.loop.spawn(
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
      if curl_process and not curl_process:is_closing() then
        curl_process:close()
        curl_process = nil
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

-- Info

---@param on_finish_callback function
local with_models_info = function(on_finish_callback)
  if not models then
    os.remove(log_path)
    local info_args = {
      info_url,
      '--silent',
      '-H',
      'Authorization: Bearer ' .. api_key,
    }

    ---@param data string
    local info_response_handler = function(data)
      local aliases = vim.json.decode(data)['aliases']
      for _, alias in ipairs(aliases) do
        if alias['name'] == 'codechat' then
          models = alias['model_ranking']
        end
      end
    end

    curl(info_args, info_response_handler, on_finish_callback)
  else
    vim.schedule(on_finish_callback)
  end
end

-- Chat completion

local chat_separator = '---------------------------------------'
local chat_system_prompt =
  'You are an AI programming assistant. Follow the users requirements carefully and to the letter. First, think step-by-step and describe your plan for what to build in pseudocode, written out in great detail. Then, output the code in a single code block. Minimize any other prose.'
local chat_buffer
local chat_win

local update_chat_window_title = function()
  vim.api.nvim_win_set_config(chat_win, {
    title = ' ' .. models[model_num] .. ' ',
    title_pos = 'center',
  })
end

---@param data string
local chat_stream_handler = function(data)
  local content = data:match '"content": "(.-)"}'
  if content then
    content = content:gsub('<', '<LT>'):gsub('\\r\\n', '\r'):gsub('\\n', '\r'):gsub('\\t', '\t'):gsub('\\"', '"')
    log(content)
    vim.api.nvim_input(content)
  end
end

local chat_exit_handler = function()
  vim.cmd 'stopinsert'
  vim.api.nvim_buf_set_lines(chat_buffer, -1, -1, true, { '', chat_separator, '' })
  vim.api.nvim_input 'G'
end

local chat_to_messages = function()
  local chat = vim.api.nvim_buf_get_lines(chat_buffer, 0, -1, true)
  local contents = { '' }
  for _, line in ipairs(chat) do
    if line:match(chat_separator) then
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
    vim.json.encode { messages = chat_to_messages(), model = models[model_num], stream = true },
  }
end

local open_chat_buffer = function()
  if not chat_buffer then
    chat_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(chat_buffer, 'filetype', 'markdown')
    vim.api.nvim_buf_set_lines(chat_buffer, 0, 0, true, { '', chat_system_prompt, '', chat_separator })
    vim.api.nvim_input 'G'

    vim.keymap.set('n', '<C-[>', function()
      vim.api.nvim_win_close(0, false)
    end, { buffer = chat_buffer })
    vim.keymap.set('n', '<C-n>', function()
      if model_num < #models then
        model_num = model_num + 1
        update_chat_window_title()
      end
    end, { buffer = chat_buffer })
    vim.keymap.set('n', '<C-p>', function()
      if model_num > 1 then
        model_num = model_num - 1
        update_chat_window_title()
      end
    end, { buffer = chat_buffer })
    vim.keymap.set({ 'n', 'i' }, '<C-CR>', function()
      if not curl_process then
        vim.cmd 'stopinsert'
        with_models_info(function()
          vim.api.nvim_buf_set_lines(chat_buffer, -1, -1, true, { '', chat_separator .. ' ' .. models[model_num], '' })
          vim.api.nvim_input 'Go'
          curl(chat_args, chat_stream_handler, chat_exit_handler)
        end)
      end
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
  with_models_info(update_chat_window_title)
end
vim.keymap.set('n', '<Tab>i', open_chat_buffer, { desc = 'OpenAi chat open' })

-- Code completion

local indentexpr
local code_system_prompt =
  'You are an expert programmer. You are requested to provide a snippet of code that performs the task requested by the user and fits best to the content of the source file. Do not indent the first line.'

local code_to_messages = function()
  local user_instruction = vim.api.nvim_get_current_line():match '^[^%w]*(.*)'

  local cursor_row = vim.fn.getcurpos()[2]
  local code_before = table.concat(vim.api.nvim_buf_get_lines(0, 0, cursor_row - 1, true), '\n')
  local code_after = table.concat(vim.api.nvim_buf_get_lines(0, cursor_row, -1, true), '\n')

  local code_user_prompt = user_instruction
    -- .. '.\n\n The filetype of the source file is '
    -- .. vim.o.filetype
    .. '.\n\nThe content of the source file before the snippet is:\n ```'
    .. vim.o.filetype
    .. '\n'
    .. code_before
    .. '\n```\n\nThe content of the source file after the snippet is:\n```'
    .. vim.o.filetype
    .. '\n'
    .. code_after
    .. '\n```'
  return { { role = 'system', content = code_system_prompt }, { role = 'user', content = code_user_prompt } }
end

local code_args = function()
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
    vim.json.encode {
      messages = code_to_messages(),
      model = models[model_num],
      stream = true,
      assistant_prefix = '```' .. vim.o.filetype .. '\n',
      stop = { '```' },
    },
  }
end

---@param data string
local code_stream_handler = function(data)
  local content = data:match '"content": "(.-)"}'
  if content then
    content = content:gsub('<', '<LT>'):gsub('\\n', '\r'):gsub('\\t', '\t'):gsub('\\"', '"')
    log(content)
    vim.api.nvim_input(content)
  end
end

local code_exit_handler = function()
  vim.cmd 'stopinsert'
  vim.bo.indentexpr = indentexpr
end

local code_complete_line = function()
  vim.cmd 'stopinsert'
  indentexpr = vim.bo.indentexpr
  vim.bo.indentexpr = tostring(vim.fn.indent(vim.api.nvim_win_get_cursor(0)[1]))
  with_models_info(function()
    vim.api.nvim_input '^C'
    curl(code_args, code_stream_handler, code_exit_handler)
  end)
end

vim.keymap.set('n', '<Leader>i', code_complete_line, { desc = 'OpenAi chat open' })
vim.keymap.set('i', '<C-[>', function()
  if curl_process then
    curl_process:kill(15)
  else
    vim.cmd 'stopinsert'
  end
end, { desc = 'OpanAi stop generation and exit to normal mode' })
