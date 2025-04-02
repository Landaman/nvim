-- Support yarn pnp by using these if they exist
local tsdkFolder = vim.fn.getcwd() .. '/.yarn/sdks/typescript/lib'
local eslintFolder = vim.fn.getcwd() .. '/.yarn/sdks'

return {
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = { 'eslint', 'vtsls' },
      handlers = {
        eslint = {
          settings = {
            nodePath = vim.fn.isdirectory(eslintFolder) == 1 and eslintFolder or nil,
          },
        },
        vtsls = {
          settings = {
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              tsdk = vim.fn.isdirectory(tsdkFolder) == 1 and tsdkFolder or nil,
              updateImportsOnFileMove = { enabled = 'always' },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = 'literals' },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
        },
      },
    },
  },
  {
    'jay-babu/mason-null-ls.nvim',
    opts = { ensure_installed = { 'prettierd' } },
  },
  {
    'mfussenegger/nvim-dap',
    opts = function()
      local dap = require 'dap'

      pcall(require, 'mason') -- make sure Mason is loaded
      local root = vim.env.MASON or (vim.fn.stdpath 'data' .. '/mason') -- Base path for the debug adapter

      -- Node options
      if not dap.adapters['node-terminal'] then
        require('dap').adapters['node-terminal'] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'node',
            args = {
              root .. '/packages/' .. 'js-debug-adapter' .. '/' .. '/js-debug/src/dapDebugServer.js',
              '${port}',
            },
          },
        }
      end

      if not dap.adapters['pwa-chrome'] then -- This is the Chrome adapter
        require('dap').adapters['pwa-chrome'] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'node',
            args = {
              root .. '/packages/' .. 'js-debug-adapter' .. '/' .. '/js-debug/src/dapDebugServer.js',
              '${port}',
            },
          },
        }
      end
      if not dap.adapters['chrome'] then -- This provides compatibility with (technically wrong) launch.json files
        dap.adapters['chrome'] = function(cb, config)
          if config.type == 'chrome' then
            config.type = 'pwa-chrome'
          end
          local nativeAdapter = dap.adapters['pwa-chrome']
          if type(nativeAdapter) == 'function' then
            nativeAdapter(cb, config)
          else
            cb(nativeAdapter)
          end
        end
      end

      if not dap.adapters['pwa-node'] then -- This is the node adapter
        require('dap').adapters['pwa-node'] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'node',
            args = {
              root .. '/packages/' .. 'js-debug-adapter' .. '/' .. '/js-debug/src/dapDebugServer.js',
              '${port}',
            },
          },
        }
      end
      if not dap.adapters['node'] then -- This provides compatibility with (technically wrong) launch.json files
        dap.adapters['node'] = function(cb, config)
          if config.type == 'node' then
            config.type = 'pwa-node'
          end
          local nativeAdapter = dap.adapters['pwa-node']
          if type(nativeAdapter) == 'function' then
            nativeAdapter(cb, config)
          else
            cb(nativeAdapter)
          end
        end
      end

      local js_filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }

      local vscode = require 'dap.ext.vscode'
      vscode.type_to_filetypes['pwa-node'] = js_filetypes
      vscode.type_to_filetypes['node'] = js_filetypes
      vscode.type_to_filetypes['pwa-chrome'] = js_filetypes
      vscode.type_to_filetypes['chrome'] = js_filetypes

      -- This makes it so that you can launch any JS/TS file in Node and can always attach in those cases
      for _, language in ipairs(js_filetypes) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = 'pwa-node',
              request = 'launch',
              name = 'Launch file (Node.js)',
              program = '${file}',
              cwd = '${workspaceFolder}',
            },
            {
              type = 'pwa-node',
              request = 'attach',
              name = 'Attach (Node.js)',
              processId = require('dap.utils').pick_process,
              cwd = '${workspaceFolder}',
            },
          }
        end
      end

      return {
        handlers = {
          -- Without this, no web debug works :(
          ['pwa-chrome'] = function(config)
            if config.webRoot == nil then
              config.webRoot = vim.fn.getcwd()
            end
            return config
          end,
          ['chrome'] = function(config)
            if config.webRoot == nil then
              config.webRoot = vim.fn.getcwd()
            end
            return config
          end,
        },
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'typescript',
        'jsdoc',
        'javascript',
      },
    },
  },
}
