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
    -- vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, bufopts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, bufopts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, bufopts)
end

local servers = {
    'lua_ls',
    'clangd',
    'pyright',
    'rust_analyzer',
    'html',
    'cssls',
    'ts_ls',
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
}

function M.setup()
    vim.diagnostic.config( {
        virtual_text = true,
        float = {
            show_header = true,
            source = "if_many",
            border = "rounded",
            focusable = false,
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = "E",
                [vim.diagnostic.severity.WARN] = "W",
                [vim.diagnostic.severity.HINT] = "H",
                [vim.diagnostic.severity.INFO] = "I",
            }
        },
        severity_sort = true,
        update_in_insert = false,
    })

    for _, server in ipairs(servers) do
        local config = vim.tbl_extend('force',
            { on_attach = on_attach },
            custom_settings[server] or {}
        )

        vim.lsp.config(server, config)
        vim.lsp.enable(server)
    end
end

return M
