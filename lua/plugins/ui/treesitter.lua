return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    event = vim.g.lazy_file,
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        cond = not vim.g.vscode,
        opts = {
          enable = true,
          max_lines = 5,
          trim_scope = 'outer',
          mode = 'cursor',
          multiline_threshold = 1,
        },
      },
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        opts = {
          select = {
            lookahead = true,
          },
          move = {
            set_jumps = true,
          },
        },
        keys = {
          {
            ';',
            function()
              require('nvim-treesitter-textobjects.repeatable_move').repeat_last_move()
            end,
            mode = { 'n', 'x', 'o' },
          },
          {
            ',',
            function()
              require('nvim-treesitter-textobjects.repeatable_move').repeat_last_move_opposite()
            end,
            mode = { 'n', 'x', 'o' },
          },
          {
            'f',
            function()
              return require('nvim-treesitter-textobjects.repeatable_move').builtin_f_expr()
            end,
            mode = { 'n', 'x', 'o' },
            expr = true,
          },
          {
            'F',
            function()
              return require('nvim-treesitter-textobjects.repeatable_move').builtin_F_expr()
            end,
            mode = { 'n', 'x', 'o' },
            expr = true,
          },
          {
            't',
            function()
              return require('nvim-treesitter-textobjects.repeatable_move').builtin_t_expr()
            end,
            mode = { 'n', 'x', 'o' },
            expr = true,
          },
          {
            'T',
            function()
              return require('nvim-treesitter-textobjects.repeatable_move').builtin_T_expr()
            end,
            mode = { 'n', 'x', 'o' },
            expr = true,
          },
          {
            ']m',
            function()
              require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Next function start',
          },
          {
            ']c',
            function()
              require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Next class start',
          },
          {
            ']a',
            function()
              require('nvim-treesitter-textobjects.move').goto_next_start('@parameter.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Next parameter start',
          },
          {
            ']M',
            function()
              require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Next function end',
          },
          {
            ']C',
            function()
              require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Next class end',
          },
          {
            ']A',
            function()
              require('nvim-treesitter-textobjects.move').goto_next_end('@parameter.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Next parameter end',
          },
          {
            '[m',
            function()
              require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Previous function start',
          },
          {
            '[c',
            function()
              require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Previous class start',
          },
          {
            '[a',
            function()
              require('nvim-treesitter-textobjects.move').goto_previous_start('@parameter.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Previous parameter start',
          },
          {
            '[M',
            function()
              require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Previous function end',
          },
          {
            '[C',
            function()
              require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Previous class end',
          },
          {
            '[A',
            function()
              require('nvim-treesitter-textobjects.move').goto_previous_end('@parameter.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Previous parameter end',
          },
          {
            'am',
            function()
              require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Around function',
          },
          {
            'im',
            function()
              require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Inside function',
          },
          {
            'ac',
            function()
              require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Around class',
          },
          {
            'ic',
            function()
              require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Inside class',
          },
          {
            'aa',
            function()
              require('nvim-treesitter-textobjects.select').select_textobject('@parameter.outer', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Around parameter',
          },
          {
            'ia',
            function()
              require('nvim-treesitter-textobjects.select').select_textobject('@parameter.inner', 'textobjects')
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Inside parameter',
          },
          {
            '[p',
            function()
              require('nvim-treesitter-textobjects.swap').swap_previous '@parameter.inner'
            end,
            mode = { 'n' },
            desc = 'Swap with previous parameter',
          },
          {
            ']p',
            function()
              require('nvim-treesitter-textobjects.swap').swap_next '@parameter.inner'
            end,
            mode = { 'n' },
            desc = 'Swap with next parameter',
          },
        },
      },
    },
    build = ':TSUpdate',
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'bash', 'diff', 'markdown', 'markdown_inline', 'query', 'regex', 'vim', 'vimdoc', 'gitcommit', 'gitignore', 'csv' },
    },
    config = function(_, opts)
      require('nvim-treesitter.config').setup(opts)
      require('nvim-treesitter.install').install(opts.ensure_installed)
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
