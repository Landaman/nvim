return {
  'mfussenegger/nvim-lint',
  -- Using BufReadPre is important to trigger the aucommand below at the right time
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    linters_by_ft = {},
  },
  config = function(_, opts)
    require('lint').linters_by_ft = opts.linters_by_ft

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave', 'TextChanged' }, {
      group = lint_augroup,
      callback = function()
        -- Only run the linter in buffers that you can modify in order to
        -- avoid superfluous noise, notably within the handy LSP pop-ups that
        -- describe the hovered symbol using Markdown.
        if vim.bo.modifiable then
          require('lint').try_lint()
        end
      end,
    })
  end,
}
