return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  cond = not vim.g.vscode,
  cmd = 'FzfLua',
  keys = {
    {
      '<leader>sf',
      function()
        require('fzf-lua').files()
      end,
      desc = 'Search files',
    },
    {
      '<leader>sF',
      function()
        require('fzf-lua').files {
          fd_opts = [[--color=never --hidden --type d --exclude .git]],
          previewer = false,
          preview = 'cd {2} && fd . -u --max-depth=1',
        }
      end,
      desc = 'Search directories',
    },
    {
      '<leader>sp',
      function()
        require('fzf-lua').builtin()
      end,
      desc = 'Search pickers',
    },
    {
      '<leader>sw',
      function()
        require('fzf-lua').grep_cword()
      end,
      desc = 'Search cursor word',
    },
    {
      '<leader>sg',
      function()
        require('fzf-lua').live_grep()
      end,
      desc = 'Search live grep',
    },
    {
      '<leader>sd',
      function()
        require('fzf-lua').diagnostics_workspace()
      end,
      desc = 'Search diagnostics',
    },
    {
      '<leader>sr',
      function()
        require('fzf-lua').resume()
      end,
      desc = 'Search resume',
    },
    {
      '<leader>s.',
      function()
        require('fzf-lua').oldfiles()
      end,
      desc = 'Search recent files',
    },
    {
      '<leader><leader>',
      function()
        require('fzf-lua').buffers()
      end,
      desc = 'Find existing buffers',
    },
    {
      '<leader>s/',
      function()
        require('fzf-lua').lgrep_curbuf()
      end,
      desc = 'Fuzzily search in current buffer',
    },
    {
      'grr',
      function()
        require('fzf-lua').lsp_references()
      end,
      desc = 'Search references',
    },
    {
      'gri',
      function()
        require('fzf-lua').lsp_implementations()
      end,
      desc = 'Search implementations',
    },
    {
      'gry',
      function()
        require('fzf-lua').lsp_typedefs()
      end,
      desc = 'Search type definitions',
    },
    {
      'gra',
      function()
        require('fzf-lua').lsp_code_actions()
      end,
      desc = 'Code actions',
    },
    {
      'gO',
      function()
        require('fzf-lua').lsp_document_symbols()
      end,
      desc = 'Search document symbols',
    },
    {
      'gP',
      function()
        require('fzf-lua').lsp_workspace_symbols()
      end,
      desc = 'Search workspace symbols',
    },
    {
      'gd',
      function()
        require('fzf-lua').lsp_definitions()
      end,
      desc = 'Search definitions',
    },
    {
      'gD',
      function()
        require('fzf-lua').lsp_declarations()
      end,
      desc = 'Search declarations',
    },
  },
  opts = {
    { 'fzf-tmux' },
    previewers = {
      codeaction_native = {
        pager = vim.fn.executable 'delta' and [[delta --width=$COLUMNS --hunk-header-style="omit" --file-style="omit"]] or nil,
      },
    },
  },
  init = function()
    vim.ui.select = function(...)
      require('fzf-lua').register_ui_select()
      vim.ui.select(...)
    end
  end,
}
