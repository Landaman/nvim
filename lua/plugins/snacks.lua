return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = 'Neovim v' .. vim.version().major .. '.' .. vim.version().minor .. '.' .. vim.version().patch,
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
    scratch = { enabled = true },
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
            desc = 'Top edge of scope',
          },
          [']i'] = {
            min_size = 1, -- allow single line scopes
            bottom = true,
            cursor = false,
            edge = true,
            treesitter = { blocks = { enabled = false } },
            desc = 'Bottom edge of scope',
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

    -- Disable the default message, to prevent FOUC on startup
    vim.opt.shortmess:append { I = true }
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
    -- Setup scratch commands
    vim.api.nvim_create_user_command('Scratch', function(cmd_opts)
      local fargs = cmd_opts.fargs
      if #fargs == 0 or fargs[1] == 'toggle' then
        Snacks.scratch()
        return
      elseif fargs[1] == 'select' then
        Snacks.scratch.select()
        return
      else
        vim.notify('Unknown argument ' .. fargs[1], vim.log.levels.ERROR)
      end
    end, {
      nargs = '?',
      complete = function()
        return { 'select', 'toggle' }
      end,
    })
    local notify = vim.notify
    require('snacks').setup(opts)
    -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
    -- this is needed to have early notifications show up in noice history
    vim.notify = notify
  end,
}
