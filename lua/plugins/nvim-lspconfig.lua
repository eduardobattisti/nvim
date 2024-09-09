local TS_INLAY_HINTS = {
  includeInlayEnumMemberValueHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayParameterNameHints = 'all',
  includeInlayParameterNameHintsWhenArgumentMatchesName = true,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayVariableTypeHints = true,
}
local TS_FILETYPES = {
  'javascript',
  'javascriptreact',
  'javascript.jsx',
  'typescript',
  'typescriptreact',
  'typescript.tsx',
  'vue',
}
local TS_SERVER = 'vtsls'
local VTSLS_TYPESCRIPT_JAVASCRIPT_CONFIG = {
  updateImportsOnFileMove = { enabled = 'always' },
  suggest = {
    completeFunctionCalls = true,
  },
  inlayHints = {
    enumMemberValues = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    parameterNames = { enabled = 'literals' },
    parameterTypes = { enabled = true },
    propertyDeclarationTypes = { enabled = true },
    variableTypes = { enabled = false },
  },
}
local TS_SERVER_HANDLERS = {
  ['textDocument/publishDiagnostics'] = function(_, result, ctx, config)
    if result.diagnostics == nil then
      return
    end

    -- ignore some tsserver diagnostics
    local idx = 1
    while idx <= #result.diagnostics do
      local entry = result.diagnostics[idx]

      -- local formatter = ergou.tsformat[entry.code]
      entry.message = formatter and formatter(entry.message) or entry.message

      -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
      if entry.code == 80001 then
        -- { message = "File is a CommonJS module; it may be converted to an ES module.", }
        table.remove(result.diagnostics, idx)
      else
        idx = idx + 1
      end
    end

    vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
  end,
}

return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },

    -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    { 'folke/neodev.nvim', opts = {} },
  },
  opts = {
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = 'if_many',
        prefix = '●',
        -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
        -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
        -- prefix = "icons",
      },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = ' ',
          [vim.diagnostic.severity.WARN] = ' ',
          [vim.diagnostic.severity.HINT] = ' ',
          [vim.diagnostic.severity.INFO] = ' ',
        },
      },
    },
  },
  config = function()
    local lspconfig = require 'lspconfig'
    local mason_registry = require 'mason-registry'
    local typescript_server_path = mason_registry.get_package('typescript-language-server'):get_install_path() .. '/node_modules/typescript/lib/tsserver.js'

    local has_volar, volar = pcall(mason_registry.get_package, 'vue-language-server')
    local vue_ts_plugin_path = volar:get_install_path() .. '/node_modules/@vue/language-server'
    local vue_plugin = {}
    if has_volar then
      vue_plugin = {
        name = '@vue/typescript-plugin',
        -- Maybe a function to get the location of the plugin is better?
        -- e.g. pnpm fallback to nvm fallback to default node path
        location = vue_ts_plugin_path,
        languages = { 'vue' },
        configNamespace = 'typescript',
        enableForWorkspaceTypeScriptVersions = true,
      }
    end

    local handlers = {
      ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded', silent = true }),
      ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded', silent = true }),
    }

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>lD', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>lds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>lws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>lr', vim.lsp.buf.rename, '[R]ename')
        map('<leader>la', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- The following autocommand is used to enable inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map('<leader>lth', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. Available keys are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    local servers = {
      vtsls = {
        handlers = TS_SERVER_HANDLERS,
        enabled = TS_SERVER == 'vtsls',
        filetypes = TS_FILETYPES,
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
            tsserver = {
              globalPlugins = {
                vue_plugin,
              },
            },
          },
          typescript = VTSLS_TYPESCRIPT_JAVASCRIPT_CONFIG,
          javascript = VTSLS_TYPESCRIPT_JAVASCRIPT_CONFIG,
        },
      },
      tsserver = {
        handlers = TS_SERVER_HANDLERS,
        enabled = TS_SERVER == 'tsserver',
        -- taken from https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
        init_options = {
          plugins = {
            vue_plugin,
          },
        },
        filetypes = TS_FILETYPES,
        settings = {
          javascript = {
            inlayHints = TS_INLAY_HINTS,
          },
          typescript = {
            inlayHints = TS_INLAY_HINTS,
          },
        },
      },
      volar = {
        init_options = {
          vue = {
            hybridMode = false,
          },
        },
      },
      tailwindcss = {
        settings = {
          tailwindCSS = {
            includeLanguages = { 'html', 'postcss', 'stylus', 'vue', 'typescrip', 'javascript' },
            experimental = {
              classRegex = {
                ---@see https://github.com/RayGuo-ergou/tailwind-intellisense-regex-list?tab=readme-ov-file#plain-javascript-object
                ---All javascript object, only enable when needed e.g. long object
                -- ':\\s*?["\'`]([^"\'`]*).*?,',
                '\\/\\*\\s*tw\\s*\\*\\/\\s*[`\'"](.*)[`\'"];?',
                '@tw\\s\\*/\\s+["\'`]([^"\'`]*)',
                { '(?:twMerge|twJoin)\\(([^\\);]*)[\\);]', '[`\'"]([^\'"`,;]*)[`\'"]' },
                'twc\\`(.*)\\`;?',
                '(?:clsx|cva|cn)[`]([\\s\\S][^`]*)[`]',
                { '(?:clsx|cva|cn)\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { 'ui:\\s*{([^)]*)\\s*}', '["\'`]([^"\'`]*).*?["\'`]' },
                { '/\\*\\s?ui\\s?\\*/\\s*{([^;]*)}', ':\\s*["\'`]([^"\'`]*).*?["\'`]' },
                'class\\s*:\\s*["\'`]([^"\'`]*)["\'`]',
                ---@see https://github.com/RayGuo-ergou/tailwind-intellisense-regex-list?tab=readme-ov-file#dom
                { 'classList.(?:add|remove)\\(([^)]*)\\)', '(?:\'|"|`)([^"\'`]*)(?:\'|"|`)' },
                ---@see https://github.com/RayGuo-ergou/tailwind-intellisense-regex-list?tab=readme-ov-file#typescript-or-javascript-variables-strings-or-arrays-with-keyword
                { 'Styles\\s*(?::\\s*[^=]+)?\\s*=\\s*([^;]*);', '[\'"`]([^\'"`]*)[\'"`]' },
                ---@see https://github.com/RayGuo-ergou/tailwind-intellisense-regex-list?tab=readme-ov-file#headlessui-transition-react
                '(?:enter|leave)(?:From|To)?=\\s*(?:"|\'|{`)([^(?:"|\'|`})]*)',
              },
            },
            classAttributes = {
              'class',
              'className',
              'class:list',
              'classList',
              'ngClass',
              'ui',
            },
          },
        },
      },
      lua_ls = {
        handlers = handlers,
      },
      -- lua_ls = {
      --   -- cmd = {...},
      --   -- filetypes = { ...},
      --   -- capabilities = {},
      --   settings = {
      --     Lua = {
      --       completion = {
      --         callSnippet = 'Replace',
      --       },
      --       -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      --       -- diagnostics = { disable = { 'missing-fields' } },
      --     },
      --   },
      -- },
    }

    -- Ensure the servers and tools above are installed
    --  To check the current status of installed tools and/or manually install
    --  other tools, you can run
    --    :Mason
    --
    --  You can press `g?` for help in this menu.
    require('mason').setup()

    -- You can add other tools here that you want Mason to install
    -- for you, so that they are available from within Neovim.
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format Lua code
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      ensure_installed = {
        'tsserver',
        'volar',
        'cssls',
        'css_variables',
        'html',
        'intelephense',
      },
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          -- This handles overriding only values explicitly passed
          -- by the server configuration above. Useful when disabling
          -- certain features of an LSP (for example, turning off formatting for tsserver)

          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
