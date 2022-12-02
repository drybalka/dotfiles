local keyopts = { noremap = true, silent = true }

local telescope = require 'telescope'
local actions = require 'telescope.actions'
local builtin = require 'telescope.builtin'

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<Esc>'] = actions.close,
        ['<C-[>'] = actions.close,
        ['<C-/>'] = actions.which_key,
      },
      n = {
        ['<C-/>'] = actions.which_key,
      },
    },
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
    diagnostics = {
      layout_strategy = 'vertical',
      layout_config = {
        mirror = true,
      },
    },
  },
  extensions = {
    ['file_browser'] = {
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
require('nvim-web-devicons').setup()
telescope.load_extension 'file_browser'

vim.keymap.set('n', '<Tab><Tab>', builtin.resume, keyopts)
vim.keymap.set('n', '<Tab><Leader>', builtin.builtin, keyopts)
vim.keymap.set('n', '<Tab>/', builtin.live_grep, keyopts)
vim.keymap.set('n', '<Tab>?', builtin.current_buffer_fuzzy_find, keyopts)
vim.keymap.set('n', '<Tab>f', builtin.find_files, keyopts)
vim.keymap.set('n', '<Tab>w', builtin.buffers, keyopts)
vim.keymap.set('n', '<Tab>o', builtin.oldfiles, keyopts)
vim.keymap.set('n', '<Tab>b', telescope.extensions.file_browser.file_browser, keyopts)
vim.keymap.set('n', '<Tab>p', builtin.registers, keyopts)

vim.keymap.set('n', '<Tab>d', builtin.diagnostics, keyopts)
vim.keymap.set('n', '<Tab>s', builtin.lsp_document_symbols, keyopts)
vim.keymap.set('n', '<Tab>r', builtin.lsp_references, keyopts)
vim.keymap.set('n', '<Tab>gs', builtin.git_status, keyopts)
vim.keymap.set('n', '<Tab>gb', builtin.git_branches, keyopts)
vim.keymap.set('n', '<Tab>gc', builtin.git_commits, keyopts)
vim.keymap.set('n', '<Tab>gf', builtin.git_bcommits, keyopts)
