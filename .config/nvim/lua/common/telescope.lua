local keyopts = { noremap = true, silent = true }


require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = require('telescope.actions').close,
        ["<c-[>"] = require('telescope.actions').close,
        ["<c-/>"] = require('telescope.actions').which_key,
      },
      n = {
        ["<c-/>"] = require('telescope.actions').which_key,
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

          vim.fn.jobstart(
            {
              'catimg', filepath,
              '-w', vim.api.nvim_win_get_width(opts.winid),
              -- '-H', vim.api.nvim_win_get_height(opts.winid),
            },
            { on_stdout = send_output, stdout_buffered = true })
        else
          require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
        end
      end
    },
  },
  pickers = {
    diagnostics = {
      layout_strategy = "vertical",
      layout_config = {
        mirror = true,
      },
    },
  },
  extensions = {
    ['file_browser'] = {
      dir_icon = "",
      cwd = "%:p:h",
      select_buffer = true,
      grouped = true,
      hide_parent_dir = true,
      initial_mode = "normal",
      mappings = {
        i = {
          ["<esc>"] = { "<esc>", type = "command" },
          ["<c-[>"] = { "<c-[>", type = "command" },
          ["<c-h>"] = require("telescope").extensions.file_browser.actions.toggle_hidden,
        },
        n = {
          ["h"] = require("telescope").extensions.file_browser.actions.goto_parent_dir,
          ["l"] = require("telescope.actions").select_default,
          ["<c-h>"] = require("telescope").extensions.file_browser.actions.toggle_hidden,
          ["<c-[>"] = require('telescope.actions').close,
        },
      },
    },
  },
}
require('telescope').load_extension 'fzf'
require 'nvim-web-devicons'.setup()
require('telescope').load_extension 'file_browser'
require('neoclip').setup({
  history = 100,
  enable_persistent_history = true,
  continuous_sync = true,
  keys = {
    telescope = {
      i = {
        paste = "<F15>",
        paste_behind = "<F16>",
      },
    }
  },
})
require('telescope').load_extension 'neoclip'

vim.keymap.set('n', '<tab><tab>', require('telescope.builtin').resume, keyopts)
vim.keymap.set('n', '<tab><leader>', require('telescope.builtin').builtin, keyopts)
vim.keymap.set('n', '<tab>/', require('telescope.builtin').live_grep, keyopts)
vim.keymap.set('n', '<tab>?', require('telescope.builtin').current_buffer_fuzzy_find, keyopts)
vim.keymap.set('n', '<tab>f', require('telescope.builtin').find_files, keyopts)
vim.keymap.set('n', '<tab>w', require('telescope.builtin').buffers, keyopts)
vim.keymap.set('n', '<tab>o', require('telescope.builtin').oldfiles, keyopts)
vim.keymap.set('n', '<tab>b', require('telescope').extensions.file_browser.file_browser, keyopts)
vim.keymap.set('n', '<tab>p', require('telescope').extensions.neoclip.neoclip, keyopts)

vim.keymap.set('n', '<tab>d', require('telescope.builtin').diagnostics, keyopts)
vim.keymap.set('n', '<tab>s', require('telescope.builtin').lsp_document_symbols, keyopts)
vim.keymap.set('n', '<tab>r', require('telescope.builtin').lsp_references, keyopts)
vim.keymap.set('n', '<tab>gs', require('telescope.builtin').git_status, keyopts)
vim.keymap.set('n', '<tab>gb', require('telescope.builtin').git_branches, keyopts)
vim.keymap.set('n', '<tab>gc', require('telescope.builtin').git_commits, keyopts)
vim.keymap.set('n', '<tab>gf', require('telescope.builtin').git_bcommits, keyopts)
