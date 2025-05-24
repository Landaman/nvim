--- Replaces the (maybe) builtin pipe call created by FZF with one that calls to wrapper scripts
---@param maybe_builtin_pipe unknown possibly a string containing a builtin pipe, but maybe something else
---@return string|unknown either a new pipe, or what was passed in
function replace_builtin_pipe(maybe_builtin_pipe)
  if type(maybe_builtin_pipe) ~= 'string' then
    return maybe_builtin_pipe
  end

  -- Get the relevant part of contents
  local _, _, first_arg = string.find(maybe_builtin_pipe, '%.spawn%_stdio%((%b[])%,')

  local base64_util = require 'fzf-lua.lib.base64'

  -- Strip out the start/end parts that we don't care about, these aren't b64
  local _, _, base64 = string.find(first_arg or '', '%[%=%=%[(.*)%]%=%=%]')
  local ok, decoded = pcall(base64_util.decode, base64)

  if not ok then
    return maybe_builtin_pipe -- If it's not base64, just return as is
  end

  -- Replace the calls if they match, otherwise ignore
  local final_spawn = decoded
  if vim.fn.executable 'fdi' then
    final_spawn = string.gsub(final_spawn, 'cmd %= "fd (.*)"', 'cmd %= "fdi %1"')
  end
  if vim.fn.executable 'rgi' then
    final_spawn = string.gsub(final_spawn, 'cmd %= "rg (.*)"', 'cmd %= "rgi %1"')
  end

  -- Re-encode the contents to be what it was except for the call
  local final_command = string.gsub(maybe_builtin_pipe, '%.spawn%_stdio%(%b[]%,', '%.spawn%_stdio%(%[%=%=%[' .. base64_util.encode(final_spawn) .. '%]%=%=%]%,')
  return final_command
end

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
  config = function(_, opts)
    -- This mess replaces the exec function with a helper
    -- that will replace fd calls with fdi calls when possible
    -- and rg calls with rgi calls when possible
    -- preserving other args in both cases
    local oldExec = require('fzf-lua.core').fzf_exec
    require('fzf-lua.core').fzf_exec = function(contents, exec_opts)
      oldExec(
        replace_builtin_pipe(contents),
        vim.tbl_deep_extend('force', exec_opts, {
          fn_reload = replace_builtin_pipe(exec_opts.fn_reload),
        })
      )
    end
    require('fzf-lua').setup(opts)
  end,
}
