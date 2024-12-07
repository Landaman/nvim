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
      '<leader>sh',
      function()
        require('telescope.builtin').help_tags()
      end,
      desc = 'Search [h]elp',
    },
    {
      '<leader>sk',
      function()
        require('telescope.builtin').keymaps()
      end,
      desc = 'Search [k]eymaps',
    },
    {
      '<leader>sf',
      function()
        -- Try defering to git for files, if that fails, use find files normally
        if not pcall(require('telescope.builtin').git_files, {
          show_untracked = true,
        }) then
          require('telescope.builtin').find_files {}
        end
      end,
      desc = 'Search [f]iles',
    },
    {
      '<leader>sF',
      function()
        require('telescope.builtin').find_files {
          hidden = true,
          no_ignore = true,
          no_ignore_parent = true,
        }
      end,
      desc = 'Search hidden [F]iles',
    },
    {
      '<leader>ss',
      function()
        require('telescope.builtin').builtin()
      end,
      desc = 'Search [s]elect Telescope',
    },
    {
      '<leader>sw',
      function()
        require('telescope.builtin').grep_string()
      end,
      desc = 'Search current [w]ord',
    },
    {
      '<leader>sg',
      function()
        require('telescope.builtin').live_grep()
      end,
      desc = 'Search by [g]rep',
    },
    {
      '<leader>sd',
      function()
        require('telescope.builtin').diagnostics()
      end,
      desc = 'Search [d]iagnostic',
    },
    {
      '<leader>sr',
      function()
        require('telescope.builtin').resume()
      end,
      desc = 'Search [r]esume',
    },
    {
      '<leader>s.',
      function()
        require('telescope.builtin').oldfiles()
      end,
      desc = '[.] Search Recent Files',
    },
    {
      '<leader><leader>',
      function()
        require('telescope.builtin').buffers()
      end,
      desc = '[ ] Find existing buffers',
    },
    {
      '<leader>/',
      function()
        require('telescope.builtin').current_buffer_fuzzy_find()
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
    {
      '<leader>s/',
      function()
        require('telescope.builtin').live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end,
      desc = '[/] Search in Open Files',
    },
    {
      '<leader>sn',
      function()
        require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = 'Search [n]eovim files',
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
      -- pickers = {}
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }
  end,
}

-- vim: ts=2 sts=2 sw=2 et
