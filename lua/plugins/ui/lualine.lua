return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = ' '
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    -- PERF: we don't need this lualine require madness 🤷
    local lualine_require = require 'lualine_require'
    lualine_require.require = require

    vim.o.laststatus = vim.g.lualine_laststatus

    return {
      options = {
        theme = 'auto',
        globalstatus = vim.o.laststatus == 3,
        icons_enabled = true,
        disabled_filetypes = {
          statusline = { 'snacks_dashboard' },
        },
      },
      sections = {
        lualine_b = {
          'branch',
          'diff',
          {
            'diagnostics',
            update_in_insert = false,
            symbols = {
              error = vim.g.diagnostic_signs[vim.diagnostic.severity.ERROR],
              warn = vim.g.diagnostic_signs[vim.diagnostic.severity.WARN],
              info = vim.g.diagnostic_signs[vim.diagnostic.severity.INFO],
              hint = vim.g.diagnostic_signs[vim.diagnostic.severity.HINT],
            },
          },
        },
        lualine_c = {
          {
            'filename',
            path = 1,
          },
        },
      },
      extensions = {
        'lazy',
        'mason',
        'oil',
        'trouble',
        'nvim-dap-ui',
      },
    }
  end,
}
