-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Buffer read/close commands
vim.keymap.set('n', '<leader>fd', function()
  vim.g.close_buffer() -- Smart close buffer based on window
end, { desc = 'Close current buffer' })
vim.keymap.set('n', '<leader>fD', function()
  vim.cmd 'bdelete' -- Close buffer and window
end, { desc = 'Delete current buffer' })

vim.keymap.set('n', '<leader>fw', function()
  vim.cmd 'w'
end, { desc = 'Write current buffer' })

-- Buffer navigation
vim.keymap.set('n', '[f', '<CMD>bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', ']f', '<CMD>bnext<CR>', { desc = 'Next buffer' })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- vim: ts=2 sts=2 sw=2 et
