--- Base handler for setting up an LSP based on parameters from either Mason or base exec
---@param server_name string the name of the server to setup
---@param handlers table<string, function | table> handlers to setup with
function base_handler(server_name, handlers)
  -- Do nothing if no handler
  if handlers[server_name] == nil then
    return
    -- Use handler in opts if we have it
  elseif type(handlers[server_name]) == 'function' then
    -- Try to see if this is just setup before the handler
    local result = handlers[server_name]()
    if not result then
      return -- If nothing, we can assume this is done
    end
  end

  -- If we got a result or we have a base handler then try setup
  if result or handlers[server_name] ~= nil then
    local server = result or handlers[server_name]

    -- Extend capabilities with blink
    server.capabilities = require('blink.cmp').get_lsp_capabilities(server.capabilities)
    require('lspconfig')[server_name].setup(server)
  end
end

return {
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    cond = not vim.g.vscode,
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    opts = {
      handlers = {}, -- Setup handlers
    },
    dependencies = {
      'saghen/blink.cmp',
      {
        'williamboman/mason-lspconfig.nvim',
        dependencies = {
          'saghen/blink.cmp',
          'williamboman/mason.nvim',
        },
        opts = {}, -- This will be populated by handlers and ensure_installed in submodules
        config = function(_, opts)
          require('mason-lspconfig').setup(vim.tbl_deep_extend('force', opts, {
            handlers = {
              function(server_name)
                base_handler(server_name, opts.handlers)
              end,
            },
          }))
        end,
      },

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      'ibhagwan/fzf-lua',
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          map('gd', require('fzf-lua').lsp_definitions, 'Goto definition')

          map('gr', require('fzf-lua').lsp_references, 'Goto references')

          map('gI', require('fzf-lua').lsp_implementations, 'Goto implementation')

          map('gy', require('fzf-lua').lsp_typedefs, 'Type definition')

          map('<leader>ds', require('fzf-lua').lsp_document_symbols, 'Document symbols')

          map('<leader>ws', require('fzf-lua').lsp_workspace_symbols, 'Workspace symbols')

          map('<leader>rn', vim.lsp.buf.rename, 'Rename')

          map('<leader>ca', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })

          map('gD', vim.lsp.buf.declaration, 'Goto declaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            map(']]', function()
              Snacks.words.jump(vim.v.count1)
            end, 'Next reference', { 'n', 't' })
            map('[[', function()
              Snacks.words.jump(-vim.v.count1)
            end, 'Previous reference', { 'n', 't' })
          end
        end,
      })

      -- Now load fallback plugins
      local handlers = vim.tbl_extend(
        'force',
        require('lazy.core.plugin').values(require('lazy.core.config').plugins['mason-lspconfig.nvim'], 'opts', false).handlers,
        opts.handlers
      ) -- Merge handlers between mason and raw

      -- Now setup each LSP that we deem should be setup this way
      for _, lsp in ipairs(opts.setup_with_executable) do
        -- If it's already setup with Mason, no need
        if not require('mason-registry').is_installed(require('mason-lspconfig').get_mappings().lspconfig_to_mason[lsp]) then
          if vim.fn.executable(lsp) == 1 then
            base_handler(lsp, handlers)
          else
            vim.notify('lspconfig: Failed to find executable for LSP ' .. lsp, vim.log.levels.WARN)
          end
        end
      end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
