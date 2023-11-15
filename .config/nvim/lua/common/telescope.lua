local telescope = require 'telescope'
local actions = require 'telescope.actions'
local builtin = require 'telescope.builtin'
local nvim_web_devicons = require 'nvim-web-devicons'

local generate_offset = function(str, tabsize)
  local offset = (tabsize - vim.fn.strdisplaywidth(str) % tabsize) % tabsize
  return string.rep(' ', offset)
end

local generate_display = function(pieces)
  local res_text = ''
  local res_highlight = {}
  for _, piece in ipairs(pieces) do
    local text, highlight = unpack(piece)
    if highlight ~= nil then
      table.insert(res_highlight, { { #res_text, #res_text + #text }, highlight })
    end
    res_text = res_text .. text
  end
  return res_text, res_highlight
end

local refine_filename = function(filename, cwd)
  if cwd ~= nil then
    cwd = vim.loop.cwd()
  end
  local relative_filename = require('plenary.path'):new(filename):make_relative(cwd)
  local name = relative_filename:match '[^/]*$'
  local dir = relative_filename:match '^.*/' or ''
  local icon, hl_icon = require('telescope.utils').transform_devicons(filename)
  icon = icon .. generate_offset(icon, 3)
  return { icon, hl_icon }, { dir, 'TelescopeResultsSpecialComment' }, { name }
end

local lsp_entry_maker = function(entry)
  local res = require('telescope.make_entry').gen_from_quickfix()(entry)
  res.display = function(entry_tbl)
    local icon, dir, name = refine_filename(entry_tbl.filename)
    local pos = ' ' .. entry_tbl.lnum .. ':' .. entry_tbl.col .. '  '
    local offset = generate_offset(icon[1] .. dir[1] .. name[1] .. pos, 10)
    local trimmed_text = entry_tbl.text:gsub('^%s*(.-)%s*$', '%1')
    return generate_display {
      icon,
      dir,
      name,
      { pos, 'TelescopeResultsLineNr' },
      { offset .. trimmed_text },
    }
  end
  return res
end

local files_entry_maker = function(entry)
  local res = require('telescope.make_entry').gen_from_file()(entry)
  res.display = function(entry_tbl)
    return generate_display { refine_filename(entry_tbl[1]) }
  end
  return res
end

local grep_entry_maker = function(entry)
  local res = require('telescope.make_entry').gen_from_vimgrep()(entry)
  res.display = function(entry_tbl)
    local _, _, filename, pos, text = string.find(entry_tbl[1], '^(.*):(%d+:%d+):(.*)$')
    local icon, dir, name = refine_filename(filename)
    local offset = generate_offset(icon[1] .. dir[1] .. name[1] .. ' ' .. pos .. '  ', 10)
    return generate_display { icon, dir, name, { ' ' .. pos .. '  ', 'TelescopeResultsLineNr' }, { offset .. text } }
  end
  return res
end

local buffers_entry_maker = function(entry)
  local res = require('telescope.make_entry').gen_from_buffer()(entry)
  res.display = function(entry_tbl)
    local icon, dir, name = refine_filename(entry_tbl.filename)
    local offset = generate_offset(tostring(entry_tbl.bufnr), 4)
    return generate_display {
      { tostring(entry_tbl.bufnr) .. offset, 'TelescopeResultsNumber' },
      { entry_tbl.indicator, 'TelescopeResultsComment' },
      icon,
      dir,
      name,
      { ' ' .. tostring(entry_tbl.lnum), 'TelescopeResultsLineNr' },
    }
  end
  return res
end

local diagnostics_entry_maker = function(entry)
  local res = require('telescope.make_entry').gen_from_diagnostics()(entry)
  res.display = function(entry_tbl)
    local sign = vim.fn.sign_getdefined('DiagnosticSign' .. entry_tbl.type:lower():gsub('^%l', string.upper))[1]
    local signature = sign.text .. ' ' .. entry_tbl.lnum .. ':' .. entry_tbl.col .. ' '
    local icon, dir, name = refine_filename(entry_tbl.filename)
    local trimmed_text = entry_tbl.text:gsub('^%s*(.-)%s*$', '%1')
    return generate_display {
      { signature .. generate_offset(signature, 11), sign.texthl },
      icon,
      dir,
      name,
      { ':  ' .. trimmed_text },
    }
  end
  return res
end

local jump_to_top = function()
  require('telescope.actions.set').select:enhance {
    post = function()
      vim.cmd 'normal zt'
    end,
  }
  return true
end

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<Esc>'] = actions.close,
        ['<C-[>'] = actions.close,
        ['<C-/>'] = actions.which_key,
        ['<C-j>'] = actions.cycle_history_next,
        ['<C-k>'] = actions.cycle_history_prev,
      },
      n = {
        ['<C-/>'] = actions.which_key,
      },
    },
    dynamic_preview_title = true,
    results_title = false,
    -- wrap_results = true,
    sorting_strategy = 'ascending',
    layout_strategy = 'flex',
    layout_config = {
      prompt_position = 'top',
      width = 0.95,
      height = 0.95,
      flex = {
        flip_columns = 200,
        flip_lines = 50,
        vertical = {
          mirror = true,
        },
        horizontal = {
          mirror = false,
        },
      },
    },
    preview = {
      mime_hook = function(filepath, bufnr, opts)
        local is_image = function(filepath)
          local image_extensions = { 'png', 'jpg' }
          local split_path = vim.split(filepath:lower(), '.', { plain = true })
          local extension = split_path[#split_path]
          return vim.tbl_contains(image_extensions, extension)
        end
        if is_image(filepath) then
          local term = vim.api.nvim_open_term(bufnr, {})
          local function send_output(_, data, _)
            for _, d in ipairs(data) do
              vim.api.nvim_chan_send(term, d .. '\r\n')
            end
          end

          vim.fn.jobstart({
            'catimg',
            filepath,
            '-w',
            vim.api.nvim_win_get_width(opts.winid),
            -- '-H', vim.api.nvim_win_get_height(opts.winid),
          }, { on_stdout = send_output, stdout_buffered = true })
        else
          require('telescope.previewers.utils').set_preview_message(bufnr, opts.winid, 'Binary cannot be previewed')
        end
      end,
    },
  },
  pickers = {
    live_grep = {
      entry_maker = grep_entry_maker,
      additional_args = { '--trim' },
    },
    find_files = {
      entry_maker = files_entry_maker,
    },
    oldfiles = {
      entry_maker = files_entry_maker,
    },
    buffers = {
      entry_maker = buffers_entry_maker,
      sort_mru = true,
      mappings = {
        i = {
          ['<C-q>'] = actions.delete_buffer,
        },
      },
    },
    lsp_references = {
      entry_maker = lsp_entry_maker,
      attach_mappings = jump_to_top,
    },
    lsp_definitions = {
      entry_maker = lsp_entry_maker,
      attach_mappings = jump_to_top,
    },
    lsp_type_definitions = {
      entry_maker = lsp_entry_maker,
      attach_mappings = jump_to_top,
    },
    lsp_implementations = {
      entry_maker = lsp_entry_maker,
      attach_mappings = jump_to_top,
    },
    diagnostics = {
      entry_maker = diagnostics_entry_maker,
      attach_mappings = jump_to_top,
      wrap_results = true,
    },
  },
  extensions = {
    file_browser = {
      dir_icon = '',
      cwd = '%:p:h',
      select_buffer = true,
      grouped = true,
      hide_parent_dir = true,
      initial_mode = 'normal',
      hidden = true,
      respect_gitignore = false,
      mappings = {
        i = {
          ['<Esc>'] = { '<Esc>', type = 'command' },
          ['<C-[>'] = { '<C-[>', type = 'command' },
          ['<C-h>'] = telescope.extensions.file_browser.actions.toggle_hidden,
        },
        n = {
          ['h'] = telescope.extensions.file_browser.actions.goto_parent_dir,
          ['l'] = actions.select_default,
          ['<C-h>'] = telescope.extensions.file_browser.actions.toggle_hidden,
          ['<C-[>'] = actions.close,
        },
      },
    },
  },
}
telescope.load_extension 'fzf'
nvim_web_devicons.setup()
telescope.load_extension 'file_browser'

vim.keymap.set('n', '<Tab><Tab>', builtin.resume, { desc = 'Telescope resume last' })
vim.keymap.set('n', '<Tab><Leader>', builtin.builtin, { desc = 'Telescope builtins' })
vim.keymap.set('n', '<Tab>/', builtin.live_grep, { desc = 'Telescope search in project' })
vim.keymap.set('n', '<Tab>?', builtin.current_buffer_fuzzy_find, { desc = 'Telescope search in file' })
vim.keymap.set('n', '<Tab>f', builtin.find_files, { desc = 'Telescope search files' })
vim.keymap.set('n', '<Tab>w', builtin.buffers, { desc = 'Telescope opened buffers' })
vim.keymap.set('n', '<Tab>o', builtin.oldfiles, { desc = 'Telescope recent files' })
vim.keymap.set('n', '<Tab>b', telescope.extensions.file_browser.file_browser, { desc = 'Telescope file browser' })
