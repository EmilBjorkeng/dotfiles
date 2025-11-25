local M = {}

local on_attach = function(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, bufopts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, bufopts)
end

local servers = {
    'lua_ls', 'clangd', 'pyright',
    'rust_analyzer', 'html','cssls',
    'ts_ls', 'jsonls', 'bashls',
    'marksman',
}

local custom_settings = {
    lua_ls = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' },
                },
                format = {
                    enable = true,
                    defaultConfig = {
                        indent_style = 'space',
                        indent_size = '4',
                        quote_style = 'single',
                    }
                },
                spell = { 'en_gb', 'no_nb' },
                telemetry = { enable = false },
            }
        },
    },
    clangd = {
        cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--cross-file-rename',
            '--completion-style=detailed',
            '--header-insertion=never',
            '--all-scopes-completion',
        },
    },
    pyright = {
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = 'basic',
                    diagnosticMode = 'workspace',
                }
            }
        },
    },
    rust_analyzer = {
        settings = {
            ['rust-analyzer'] = {
                checkOnSave = {
                    command = 'clippy',
                },
                cargo = {
                    allFeatures = true,
                },
            }
        },
    },
    ts_ls = {
        settings = {
            typescript = {
                inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayFunctionParameterTypeHints = true,
                },
            },
            javascript = {
                inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayFunctionParameterTypeHints = true,
                },
            },
        },
    },
}

function M.setup()
    local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    local capabilities = has_cmp and cmp_nvim_lsp.default_capabilities() or {}

    vim.diagnostic.config({
        virtual_text = true,
        float = {
            show_header = true,
            source = 'if_many',
            border = 'rounded',
            focusable = false,
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = 'E',
                [vim.diagnostic.severity.WARN] = 'W',
                [vim.diagnostic.severity.HINT] = 'H',
                [vim.diagnostic.severity.INFO] = 'I',
            },
        },
        severity_sort = true,
        update_in_insert = false,
        underline = true,
    })

        for _, server in ipairs(servers) do
        local config = vim.tbl_extend('force',
            {
                on_attach = on_attach,
                capabilities = capabilities,
            },
            custom_settings[server] or {}
        )

        vim.lsp.config(server, config)
        local ok = pcall(vim.lsp.enable, server)
        if not ok then
            vim.notify('LSP server not found: ' .. server, vim.log.levels.WARN)
        end
    end
end

return M
