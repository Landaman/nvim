return {
  'akinsho/bufferline.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>fp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Toggle [p]in' },
    { '<leader>fP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete non-[P]inned buffers' },
    { '<leader>fo', '<Cmd>BufferLineCloseOthers<CR>', desc = 'Delete [o]ther buffers' },
    { '<leader>fr', '<Cmd>BufferLineCloseRight<CR>', desc = 'Delete buffers to the [r]ight' },
    { '<leader>fl', '<Cmd>BufferLineCloseLeft<CR>', desc = 'Delete buffers to the [l]eft' },
    { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous buffer' },
    { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
    { '[f', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous bu[f]fer' },
    { ']f', '<cmd>BufferLineCycleNext<cr>', desc = 'Next bu[f]fer' },
    { '[F', '<cmd>BufferLineMovePrev<cr>', desc = 'Move bu[F]fer previous' },
    { ']F', '<cmd>BufferLineMoveNext<cr>', desc = 'Move bu[F]fer next' },
  },
  opts = {
    options = {
      close_command = vim.g.close_buffer,
      diagnostics_indicator = function(_, _, diag)
        local s = ''
        for e, n in pairs(diag) do
          local sym = e == 'error' and vim.g.diagnostic_signs[vim.diagnostic.severity.ERROR]
            or (e == 'warning' and vim.g.diagnostic_signs[vim.diagnostic.severity.WARN])
            or e == 'info' and vim.g.diagnostic_signs[vim.diagnostic.severity.INFO]
            or vim.g.diagnostic_signs[vim.diagnostic.severity.HINT]
          s = s .. ' ' .. sym .. n
          return s
        end
      end,
      diagnostics = 'nvim_lsp',
      always_show_bufferline = false,
      offsets = {
        {
          filetype = 'neo-tree',
          text = 'Neo-tree',
          highlight = 'Directory',
          text_align = 'left',
        },
      },
    },
  },
}
