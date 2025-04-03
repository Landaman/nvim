return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = not vim.g.vscode },
    dashboard = {
      enabled = not vim.g.vscode,
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
    quickfile = { enabled = not vim.g.vscode },
    statuscolumn = { enabled = not vim.g.vscode },
    words = { enabled = not vim.g.vscode },
    scratch = { enabled = not vim.g.vscode },
    scope = {
      enabled = true,
      keys = {
        textobject = {
          ii = {
            desc = 'Inner scope',
          },
          ai = {
            desc = 'Full scope',
          },
        },
        jump = {
          ['[i'] = {
            desc = 'Top edge of scope',
          },
          [']i'] = {
            desc = 'Bottom edge of scope',
          },
        },
      },
    },
  },
  init = function()
    -- Disable the default message, to prevent FOUC on startup
    vim.opt.shortmess:append { I = true }
  end,
  config = function(_, opts)
    -- Setup scratch commands
    if opts.scratch.enabled then
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
    end

    require('snacks').setup(opts)

    -- Override jump to make a mark in the jumplist prior to jumping
    local old_jump = require('snacks.scope').jump
    require('snacks.scope').jump = function(...)
      vim.cmd.normal "m'"
      old_jump(...)
    end
  end,
}
