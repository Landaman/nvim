-- NOTE: Plugins can specify dependencies.
--
-- The dependencies are proper plugin specifications as well - anything
-- you do for a plugin at the top level, you can do for a dependency.
--
-- Use the `dependencies` key to specify the dependencies of a particular plugin

return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  keys = {
    {
      '<leader>s?',
      function()
        require('telescope.builtin').help_tags()
      end,
      desc = 'Search help',
    },
    {
      '<leader>sk',
      function()
        require('telescope.builtin').keymaps()
      end,
      desc = 'Search keymaps',
    },
    {
      '<leader>sf',
      function()
        -- Try deferring to git for files, if that fails, use find files normally
        if not pcall(require('telescope.builtin').git_files, {}) then
          require('telescope.builtin').find_files {}
        end
      end,
      desc = 'Search files',
    },
    {
      '<leader>sF',
      function()
        require('telescope').extensions.oil.oil()
      end,
      desc = 'Search directories',
    },
    {
      '<leader>sh',
      function()
        require('telescope.builtin').find_files {
          hidden = true,
          no_ignore = true,
          no_ignore_parent = true,
          prompt_title = 'All Files',
        }
      end,
      desc = 'Search hidden files',
    },
    {
      '<leader>sH',
      function()
        require('telescope').extensions.oil.oil {
          hidden = true,
          no_ignore = true,
          prompt_title = 'All Directories',
        }
      end,
      desc = 'Search hidden directories',
    },
    {
      '<leader>ss',
      function()
        require('telescope.builtin').builtin()
      end,
      desc = 'Search Telescopes',
    },
    {
      '<leader>sw',
      function()
        require('telescope.builtin').grep_string()
      end,
      desc = 'Search current word',
    },
    {
      '<leader>sg',
      function()
        require('telescope.builtin').live_grep()
      end,
      desc = 'Search grep',
    },
    {
      '<leader>sd',
      function()
        require('telescope.builtin').diagnostics()
      end,
      desc = 'Search diagnostics',
    },
    {
      '<leader>sr',
      function()
        require('telescope.builtin').resume()
      end,
      desc = 'Search resume',
    },
    {
      '<leader>s.',
      function()
        require('telescope.builtin').oldfiles()
      end,
      desc = 'Search recent files',
    },
    {
      '<leader><leader>',
      function()
        require('telescope.builtin').buffers()
      end,
      desc = 'Find existing buffers',
    },
    {
      '<leader>/',
      function()
        require('telescope.builtin').current_buffer_fuzzy_find()
      end,
      desc = 'Fuzzily search in current buffer',
    },
    {
      '<leader>s/',
      function()
        require('telescope.builtin').live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end,
      desc = 'Search in open files',
    },
    {
      '<leader>sn',
      function()
        require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = 'Search neovim files',
    },
  },
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = true },
    { 'folke/trouble.nvim' },
  },
  opts = function()
    --- Pre-processes a filter to contain the items in the form Telescope expects
    ---@param filter {folders: table<string>, files: table<string>}
    ---@return table<string> resulting files
    local function pre_process_filters(filter)
      local folders = vim.tbl_map(function(folder)
        return folder .. '%/.*'
      end, filter.folders)
      local files = filter.files

      -- Join them
      local joined = vim.list_extend(folders, files)

      local result = vim
        .iter(joined)
        :map(function(value)
          return {
            '/' .. value,
            '^' .. value,
          }
        end)
        :flatten()
        :map(function(value)
          return vim.g.os_encode_path_separators(value) -- Encode the path separators
        end)
        :totable()

      return result
    end
    return {
      defaults = {
        file_ignore_patterns = pre_process_filters(vim.g.file_visibility.hide),
        mappings = {
          n = {
            ['<C-Q>'] = require('trouble.sources.telescope').open,
            ['<C-q>'] = require('trouble.sources.telescope').open,
            ['<M-q>'] = require('telescope.actions').nop,
          },
        },
      },
      pickers = {
        git_files = {
          show_untracked = true,
        },
        colorscheme = {
          enable_preview = true,
        },
      },
      extensions = {
        oil = {
          hidden = true,
          debug = false,
          no_ignore = false,
          show_preview = true,
        },
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }
  end,
  init = function()
    -- This makes it so that no matter what we load Telescope and it's picker when we try to select
    vim.ui.select = function(...)
      require('lazy').load { plugins = { 'telescope.nvim' } }
      vim.ui.select(...)
    end
  end,
  config = function(_, opts)
    require('telescope').setup(opts)
    require('telescope').load_extension 'ui-select' -- Setup the UI selector
  end,
}

-- vim: ts=2 sts=2 sw=2 et
