local M = {}

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local bufnr = args.buf
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
        cmd          = { os.getenv('HOME') .. '/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer' },
        filetypes    = { 'rust' },
        root_markers = { 'Cargo.toml', 'Cargo.lock' },
        settings = {
            ['rust-analyzer'] = {
                checkOnSave = true,
                check = {
                    command = 'clippy',
                },
                cargo = {
                    allFeatures = true,
                },
                inlayHints = {
                    bindingModeHints       = { enable = true },
                    chainingHints          = { enable = true },
                    parameterHints         = { enable = true },
                    typeHints              = { enable = true },
                    closureReturnTypeHints = { enable = 'always' },
                },
                procMacro = {
                    enable = true,
                },
                imports = {
                    granularity = { group = 'module' },
                    prefix      = 'self',
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
                    includeInlayParameterNameHints      = 'all',
                    includeInlayFunctionParameterTypeHints = true,
                },
            },
            javascript = {
                inlayHints = {
                    includeInlayParameterNameHints      = 'all',
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
            client.stop()
            vim.defer_fn(function()
                vim.lsp.enable(client.name)
            end, 500)
        end
    end, {})

    vim.api.nvim_create_user_command('LspStop', function()
        for _, client in ipairs(vim.lsp.get_clients()) do
            client.stop()
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
