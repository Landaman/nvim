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
          -- postgrestools are not natively supported, so add support manually here
          require('mason-lspconfig.mappings.server').lspconfig_to_package['postgres_lsp'] = 'postgrestools'
          require('mason-lspconfig.mappings.server').package_to_lspconfig['postgrestools'] = 'postgres_lsp'

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
    },
    config = function(_, opts)
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
