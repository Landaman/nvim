-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  init = function()
    -- This allows Neotree to override NETRW on startup
    vim.api.nvim_create_autocmd('BufNewFile', {
      group = vim.api.nvim_create_augroup('RemoteFile', { clear = true }), -- Remote environments
      callback = function()
        local f = vim.fn.expand '%:p'
        for _, v in ipairs { 'sftp', 'scp', 'ssh', 'dav', 'fetch', 'ftp', 'http', 'rcp', 'rsync' } do
          local p = v .. '://'
          if string.sub(f, 1, #p) == p then -- Allow NETRW to load
            vim.cmd [[
          unlet g:loaded_netrw
          unlet g:loaded_netrwPlugin
          runtime! plugin/netrwPlugin.vim
 (1, 1)         silent Explore %
        ]]
            vim.api.nvim_clear_autocmds { group = 'RemoteFile' }
            break
          end
        end
      end,
    })
    vim.api.nvim_create_autocmd('BufEnter', {
      group = vim.api.nvim_create_augroup('NeoTreeInit', { clear = true }), -- Initialize NeoTree
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
  opts = function()
    --- Pre-processes a filter to contain the items in the form Neo-Tree expects
    ---@param filter {folders: table<string>, files: table<string>}
    ---@return table<string> resulting files
    function pre_process_filters(filter)
      -- Get folders and files preprocessed
      local folders = filter.folders
      local files = filter.files

      -- Join them
      local joined = vim.tbl_map(function(path)
        if path[0] == '/' then
          return path -- If we actually want it at the start, respect that
        end
        return '**/' .. path -- For some reason, if you don't do this, some globs don't work 🤷
      end, vim.list_extend(folders, files))

      return vim.tbl_map(function(path)
        local result, _ = path:gsub('\\', '\\\\') -- For some reason we delete the \s on Windows if we don't do this
        return result
      end, vim.tbl_map(vim.g.os_encode_path_separators, joined))
    end

    return {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_hidden = false,
          hide_by_pattern = pre_process_filters(vim.g.file_visibility.hide),
          never_show_by_pattern = pre_process_filters(vim.g.file_visibility.never_show),
          always_show_by_pattern = pre_process_filters(vim.g.file_visibility.always_show),
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
    }
  end,
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
