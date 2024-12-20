-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Buffer read/close commands
vim.keymap.set('n', '<leader>fd', function()
  vim.g.close_buffer() -- Smart close buffer based on window
end, { desc = '[d] Close current buffer' })
vim.keymap.set('n', '<leader>fD', function()
  vim.cmd 'bdelete' -- Close buffer and window
end, { desc = '[D]elete current buffer' })

vim.keymap.set('n', '<leader>fw', function()
  vim.cmd 'w'
end, { desc = '[w]rite current buffer' })

-- Snippet navigation
vim.keymap.set({ 'i', 's' }, '<C-l>', function()
  if vim.snippet.active { direction = 1 } then
    vim.schedule(function()
      vim.snippet.jump(1)
    end)
    return
  end
end, {
  desc = 'Snippet: Jump forward',
})
vim.keymap.set({ 'i', 's' }, '<C-h>', function()
  if vim.snippet.active { direction = -1 } then
    vim.schedule(function()
      vim.snippet.jump(-1)
    end)
    return
  end
end, {
  desc = 'Snippet: Jump backward',
})

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
