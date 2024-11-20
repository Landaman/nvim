-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  init = function()
    vim.api.nvim_create_autocmd('BufNewFile', {
      group = vim.api.nvim_create_augroup('RemoteFile', { clear = true }),
      callback = function()
        local f = vim.fn.expand '%:p'
        for _, v in ipairs { 'sftp', 'scp', 'ssh', 'dav', 'fetch', 'ftp', 'http', 'rcp', 'rsync' } do
          local p = v .. '://'
          if string.sub(f, 1, #p) == p then
            vim.cmd [[
          unlet g:loaded_netrw
          unlet g:loaded_netrwPlugin
          runtime! plugin/netrwPlugin.vim
          silent Explore %
        ]]
            vim.api.nvim_clear_autocmds { group = 'RemoteFile' }
            break
          end
        end
      end,
    })
    vim.api.nvim_create_autocmd('BufEnter', {
      group = vim.api.nvim_create_augroup('NeoTreeInit', { clear = true }),
      callback = function()
        local f = vim.fn.expand '%:p'
        if vim.fn.isdirectory(f) ~= 0 then
          require('neo-tree.command').execute { reveal = true, source = 'filesystem', dir = f }
          vim.api.nvim_clear_autocmds { group = 'NeoTreeInit' }
        end
      end,
    })
  end,
  keys = {
    {
      '\\',
      function()
        require('neo-tree.command').execute { toggle = true }
      end,
      desc = 'NeoTree reveal',
      silent = true,
    },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_hidden = false,
        hide_by_pattern = {
          '**/.git',
          '**/node_modules',
          '**/.venv',
          '**/__pycache__',
          '**/.metals',
          '**/.bloop',
          '**/.ammonite',
          '**/metals.sbt',
        },
        never_show_by_pattern = {
          '**/.git',
          '**/.DS_Store',
        },
      },
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      hijack_netrw_behavior = 'open_default',
      use_libuv_file_watcher = false,
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = '',
        expander_expanded = '',
      },
      git_status = {
        symbols = {
          unstaged = '󰄱',
          staged = '󰱒',
        },
      },
    },
  },
  config = function(_, opts)
    local function on_move(data)
      Snacks.rename.on_rename_file(data.source, data.destination)
    end

    local events = require 'neo-tree.events'
    opts.event_handlers = opts.event_handlers or {}
    vim.list_extend(opts.event_handlers, {
      { event = events.FILE_MOVED, handler = on_move },
      { event = events.FILE_RENAMED, handler = on_move },
    })
    require('neo-tree').setup(opts)
  end,
}
