return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
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
        main = 'nvim-treesitter.configs', -- Sets main module to use for opts
        opts = {
          textobjects = {
            select = {
              enable = true,

              -- Automatically jump forward to textobj, similar to targets.vim
              lookahead = true,

              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['am'] = { query = '@function.outer', desc = 'LSP: [m] Around function' },
                ['im'] = { query = '@function.inner', desc = 'LSP: [m] Inside function' },
                ['ac'] = { query = '@class.outer', desc = 'LSP: Around [c]lass' },
                ['ic'] = { query = '@class.inner', desc = 'LSP: Inside [c]lass' },
                ['aa'] = { query = '@parameter.outer', desc = 'LSP: Around p[a]rameter' },
                ['ia'] = { query = '@parameter.inner', desc = 'LSP: Inside p[a]rameter' },
              },
              -- You can choose the select mode (default is charwise 'v')
              --
              -- Can also be a function which gets passed a table with the keys
              -- * query_string: eg '@function.inner'
              -- * method: eg 'v' or 'o'
              -- and should return the mode ('v', 'V', or '<c-v>') or a table
              -- mapping query_strings to modes.
              selection_modes = {},
              -- If you set this to `true` (default is `false`) then any textobject is
              -- extended to include preceding or succeeding whitespace. Succeeding
              -- whitespace has priority in order to act similarly to eg the built-in
              -- `ap`.
              --
              -- Can also be a function which gets passed a table with the keys
              -- * query_string: eg '@function.inner'
              -- * selection_mode: eg 'v'
              -- and should return true or false
              include_surrounding_whitespace = true,
            },
            swap = {
              enable = true,
              swap_previous = {
                ['<leader>A'] = { query = '@parameter.inner', desc = 'LSP: Swap with previous p[A]rameter' },
              },
              swap_next = {
                ['<leader>a'] = { query = '@parameter.inner', desc = 'LSP: Swap with next p[a]rameter' },
              },
            },
            lsp_interop = {
              enable = true,
              border = 'none',
              floating_preview_opts = {},
              peek_definition_code = {
                ['<leader>pm'] = { query = '@function.outer', desc = 'LSP: [m] Peek outer function' },
                ['<leader>pc'] = { query = '@class.outer', desc = 'LSP: Peek outer [c]lass' },
              },
            },
            move = {
              enable = true,
              set_jumps = true, -- whether to set jumps in the jumplist
              goto_next_start = {
                [']m'] = { query = '@function.outer', desc = 'LSP: [m] Next function start' },
                [']c'] = { query = '@class.outer', desc = 'LSP: Next [c]lass start' },
                [']a'] = { query = '@parameter.outer', desc = 'LSP: Next p[a]rameter start' },
              },
              goto_next_end = {
                [']M'] = { query = '@function.outer', desc = 'LSP: [M] Next function end' },
                [']C'] = { query = '@class.outer', desc = 'LSP: Next [C]lass end' },
                [']A'] = { query = '@parameter.outer', desc = 'LSP: Next p[A]rameter end' },
              },
              goto_previous_start = {
                ['[m'] = { query = '@function.outer', desc = 'LSP: [m] Previous function start' },
                ['[c'] = { query = '@class.outer', desc = 'LSP: Previous [c]lass start' },
                ['[a'] = { query = '@parameter.outer', desc = 'LSP: Previous p[a]rameter start' },
              },
              goto_previous_end = {
                ['[M'] = { query = '@function.outer', desc = 'LSP: [M] Previous function end' },
                ['[C'] = { query = '@class.outer', desc = 'LSP: Previous [C]lass end' },
                ['[A'] = { query = '@parameter.outer', desc = 'LSP: Previous p[A]rameter end' },
              },
            },
          },
        },
        on_attach = function()
          local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'

          -- vim way: ; goes to the direction you were moving.
          vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move)
          vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_opposite)

          -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
          vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
          vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
          vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
          vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })
        end,
      },
    },
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'regex', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
