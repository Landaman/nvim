local function is_null_ls_formatting_enabled(bufnr)
  local file_type = vim.bo[bufnr].filetype
  local generators = require('null-ls.generators').get_available(file_type,
    require('null-ls.methods').internal.FORMATTING)
  return #generators > 0
end

local function format_with_lsp(bufnr)
  vim.lsp.buf.format {
    filter = function(client)
      return client.name == 'null-ls' or not is_null_ls_formatting_enabled(bufnr)
    end,
    bufnr = bufnr,
  }
end

return {
  {
    'nvimtools/none-ls.nvim',
    cond = not vim.g.vscode,
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    dependencies = {
      {
        'jay-babu/mason-null-ls.nvim',
        dependencies = {
          'williamboman/mason.nvim',
        },
        opts = {
          handlers = {},
          automatic_installation = false,
          ensure_installed = {
            'markdownlint',
            'cspell',
          },
        },
      },
      'davidmh/cspell.nvim',
    },
    config = function()
      local null_ls = require 'null-ls'
      local cspell = require 'cspell'

      vim.keymap.set({ 'n' }, '<leader>ff', function()
        format_with_lsp(vim.api.nvim_get_current_buf())
      end, { desc = 'Format buffer' })

      local lsp_save_augroup = vim.api.nvim_create_augroup('LspSaveFormatting', {})
      null_ls.setup {
        update_in_insert = false,
        on_attach = function(_, bufnr)
          vim.api.nvim_clear_autocmds { group = lsp_save_augroup, buffer = bufnr }
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = lsp_save_augroup,
            buffer = bufnr,
            callback = function()
              format_with_lsp(bufnr)
            end,
          })
        end,

        sources = {
          cspell.diagnostics.with {
            -- info rather than errors
            disabled_filetypes = { 'bigfile' },
            diagnostics_postprocess = function(diagnostic)
              diagnostic.severity = vim.diagnostic.severity.INFO
            end,
          },
          cspell.code_actions.with {
            -- info rather than errors
            disabled_filetypes = { 'bigfile' },
            diagnostics_postprocess = function(diagnostic)
              diagnostic.severity = vim.diagnostic.severity.INFO
            end,
          },
        },
      }
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
