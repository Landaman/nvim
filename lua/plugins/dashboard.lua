return {
  'nvimdev/dashboard-nvim',
  lazy = false,
  opts = {
    theme = 'hyper',
    hide = {
      -- this is taken care of by lualine
      -- enabling this messes up the actual laststatus setting after loading a file
      statusline = false,
    },
    shortcut_type = 'number',
    config = {
      week_header = {
        enable = true,
      },
      project = {
        enable = true,
        limit = 15,
        action = function(path)
          vim.cmd('cd ' .. path)
          vim.cmd 'Telescope find_files'
        end,
      },
      shortcut = {},
      mru = { enable = false, limit = 0 },
      packages = { enable = false },
      footer = function()
        local stats = require('lazy').stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        return { '', '', '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
      end,
    },
  },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
}
