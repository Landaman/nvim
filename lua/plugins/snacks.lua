return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = ' ', key = 'f', desc = 'Find File', action = '<leader>sf' },
          { icon = ' ', key = 'F', desc = 'Find Directory', action = '<leader>sF' },
          { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
          { icon = ' ', key = 'g', desc = 'Find Text', action = '<leader>sg' },
          {
            icon = ' ',
            key = 'c',
            desc = 'Config',
            action = function()
              vim.cmd('cd ' .. vim.fn.stdpath 'config')
              Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath 'config' })
            end,
          },
          { icon = '󰒲 ', key = 'a', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
    },
    notifier = { enabled = true, timeout = 3000 },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    input = { enabled = true },
    words = { enabled = true },
    scope = {
      enabled = true,
      keys = {
        textobject = {
          ii = {
            min_size = 2, -- minimum size of the scope
            edge = false, -- inner scope
            cursor = false,
            treesitter = { blocks = { enabled = false } },
            desc = 'Inner scope',
          },
          ai = {
            cursor = false,
            min_size = 2, -- minimum size of the scope
            treesitter = { blocks = { enabled = false } },
            desc = 'Full scope',
          },
        },
        jump = {
          ['[i'] = {
            min_size = 1, -- allow single line scopes
            bottom = false,
            cursor = false,
            edge = true,
            treesitter = { blocks = { enabled = false } },
            desc = 'Jump to top edge of scope',
          },
          [']i'] = {
            min_size = 1, -- allow single line scopes
            bottom = true,
            cursor = false,
            edge = true,
            treesitter = { blocks = { enabled = false } },
            desc = 'Jump to bottom edge of scope',
          },
        },
      },
    },
    styles = {
      notification = {
        wo = { wrap = true }, -- Wrap notifications
      },
    },
  },
  init = function()
    vim.print = function(...)
      Snacks.debug.inspect(...)
    end
  end,
  keys = {
    {
      '<leader>n',
      function()
        Snacks.notifier.hide()
      end,
      desc = 'Dismiss notifications',
    },
  },
  config = function(_, opts)
    local notify = vim.notify
    require('snacks').setup(opts)
    -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
    -- this is needed to have early notifications show up in noice history
    vim.notify = notify
  end,
}
