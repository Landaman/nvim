return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
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
      desc = 'Dismiss [n]otifications',
    },
  },
}
