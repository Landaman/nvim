-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following Lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do

if not vim.g.vscode then
  vim.keymap.set('n', ']g', function()
    require('vscode').call 'workbench.action.editor.nextChange'
  end, { desc = 'Next change' })
  vim.keymap.set('n', '[g', function()
    require('vscode').call 'workbench.action.editor.prevChange'
  end, { desc = 'Previous change' })
end

return {
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    cond = not vim.g.vscode,
    cmd = 'Gitsigns',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']g', function()
          if vim.wo.diff then
            vim.cmd.normal { ']g', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Next git change' })

        map('n', '[g', function()
          if vim.wo.diff then
            vim.cmd.normal { '[g', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Previous git change' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Stage git hunk toggle' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Git stage hunk toggle' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Git reset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Git stage buffer' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Git reset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Git preview hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Git blame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Git diff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'Git diff against last commit' })
        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Toggle git show blame line' })
        map('n', '<leader>tp', gitsigns.preview_hunk_inline, { desc = 'Toggle git inline hunk preview' })
      end,
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
