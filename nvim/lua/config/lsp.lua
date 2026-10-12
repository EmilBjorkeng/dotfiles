local M = {}

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
    callback = function(args)
        local bufnr = args.buf
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        local function map(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, vim.tbl_extend('force', bufopts, { desc = 'LSP: ' .. desc }))
        end

        map('gd', vim.lsp.buf.definition, 'Go to definition')
        map('K', vim.lsp.buf.hover, 'Hover documentation')
        map('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
        map('gr', vim.lsp.buf.references, 'References')
        map('gD', vim.lsp.buf.declaration, 'Go to declaration')
        map('gi', vim.lsp.buf.implementation, 'Go to implementation')
        map('gt', vim.lsp.buf.type_definition, 'Go to type definition')
        map('<leader>e', vim.diagnostic.open_float, 'Show diagnostic')
        map('<leader>q', vim.diagnostic.setloclist, 'Diagnostics to location list')

        if client and client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

            map('<leader>ih', function()
                local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
                vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
            end, 'Toggle inlay hints')
        end

        vim.lsp.document_color.enable(false, { bufnr = bufnr })
    end,
})

local servers = {
    'lua_ls', 'clangd', 'pyright',
    'rust_analyzer', 'html', 'cssls',
    'ts_ls', 'jsonls', 'bashls',
    'marksman',
}

local custom_settings = {
    lua_ls = {
        cmd          = { 'lua-language-server' },
        filetypes    = { 'lua' },
        root_markers = { '.luarc.json', '.git' },
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' },
                },
                format = {
                    enable = true,
                    defaultConfig = {
                        indent_style = 'space',
                        indent_size  = '4',
                        quote_style  = 'single',
                    }
                },
                spell      = { 'en_gb', 'no_nb' },
                telemetry  = { enable = false },
            }
        },
    },
    clangd = {
        filetypes    = { 'c', 'cpp', 'objc', 'objcpp' },
        cmd          = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--cross-file-rename',
            '--completion-style=detailed',
            '--header-insertion=never',
            '--all-scopes-completion',
        },
        root_markers = { 'compile_commands.json', '.git', 'CMakeLists.txt' },
    },
    pyright = {
        cmd          = { 'pyright-langserver', '--stdio' },
        filetypes    = { 'python' },
        root_markers = { 'pyproject.toml', 'setup.py', '.git' },
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = 'basic',
                    diagnosticMode   = 'workspace',
                }
            }
        },
    },
    rust_analyzer = {
        cmd          = { 'rust-analyzer' },
        filetypes    = { 'rust' },
        root_markers = { 'Cargo.toml', 'Cargo.lock' },
        settings = {
            ['rust-analyzer'] = {
                checkOnSave = true,
                check = {
                    command = 'clippy',
                },
                cargo = {
                    features = 'all',
                },
                inlayHints = {
                    bindingModeHints       = { enable = true },
                    chainingHints          = { enable = true },
                    parameterHints         = { enable = true },
                    typeHints              = { enable = true },
                    closureReturnTypeHints = { enable = 'always' },
                },
                imports = {
                    granularity = { group = 'module' },
                    prefix      = 'plain',
                },
            },
        },
    },
    ts_ls = {
        cmd          = { 'typescript-language-server', '--stdio' },
        filetypes    = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
        root_markers = { 'package.json', 'tsconfig.json', '.git' },
        settings = {
            typescript = {
                inlayHints = {
                    includeInlayParameterNameHints         = 'all',
                    includeInlayFunctionParameterTypeHints = true,
                },
            },
            javascript = {
                inlayHints = {
                    includeInlayParameterNameHints         = 'all',
                    includeInlayFunctionParameterTypeHints = true,
                },
            },
        },
    },
    bashls = {
        cmd          = { 'bash-language-server', 'start' },
        filetypes    = { 'sh', 'bash' },
        root_markers = { '.git' },
    },
    cssls = {
        cmd          = { 'vscode-css-language-server', '--stdio' },
        filetypes    = { 'css', 'scss', 'less' },
        root_markers = { 'package.json', '.git' },
    },
    html = {
        cmd          = { 'vscode-html-language-server', '--stdio' },
        filetypes    = { 'html' },
        root_markers = { 'package.json', '.git' },
    },
    jsonls = {
        cmd          = { 'vscode-json-language-server', '--stdio' },
        filetypes    = { 'json', 'jsonc' },
        root_markers = { '.git' },
    },
    marksman = {
        cmd          = { 'marksman', 'server' },
        filetypes    = { 'markdown' },
        root_markers = { '.git', '.marksman.toml' },
    },
}

function M.setup()
    local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    local capabilities = has_cmp and cmp_nvim_lsp.default_capabilities() or {}

    vim.lsp.log.set_level(vim.log.levels.ERROR)

    vim.diagnostic.config({
        virtual_text = true,
        float = {
            show_header = true,
            source      = 'if_many',
            border      = 'rounded',
            focusable   = false,
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = 'E',
                [vim.diagnostic.severity.WARN]  = 'W',
                [vim.diagnostic.severity.HINT]  = 'H',
                [vim.diagnostic.severity.INFO]  = 'I',
            },
        },
        severity_sort    = true,
        update_in_insert = false,
        underline        = true,
    })

    vim.api.nvim_create_user_command('LspRestart', function()
        local clients = vim.lsp.get_clients()
        for _, client in ipairs(clients) do
            client:stop()
            vim.defer_fn(function()
                vim.lsp.enable(client.name)
            end, 500)
        end
    end, {})

    vim.api.nvim_create_user_command('LspStop', function()
        for _, client in ipairs(vim.lsp.get_clients()) do
            client:stop()
        end
    end, {})

    vim.api.nvim_create_user_command('LspStart', function()
        for _, server in ipairs(servers) do
            vim.lsp.enable(server)
        end
    end, {})

    vim.api.nvim_create_user_command('LspInfo', function()
        local clients = vim.lsp.get_clients()
        if #clients == 0 then
            vim.notify('No LSP clients attached', vim.log.levels.INFO)
            return
        end
        for _, client in ipairs(clients) do
            vim.notify(
                string.format('[%d] %s — root: %s', client.id, client.name, client.root_dir or 'none'),
                vim.log.levels.INFO
            )
        end
    end, {})

    vim.api.nvim_create_user_command('LspLog', function()
        vim.cmd('edit ' .. vim.lsp.get_log_path())
    end, {})

    for _, server in ipairs(servers) do
        local config = vim.tbl_extend('force',
            { capabilities = capabilities },
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

