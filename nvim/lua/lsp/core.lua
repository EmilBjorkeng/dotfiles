local M = {}

local servers = {
    lua_language_server = {
        name = 'luals',
        binary_path = 'lua-language-server',
        filetype = { 'lua' },
    },
    cpp_language_server = {
        name = 'clangd',
        binary_path = 'clangd',
        filetype = { 'c', 'cpp', 'objc', 'objcpp' },
    },
    python_language_server = {
        name = 'pyright',
        binary_path = 'pyright-langserver',
        filetype = { 'python' },
    },
    rust_language_server = {
        name = 'rust-analyzer',
        binary_path = 'rust-analyzer',
        filetype = { 'rust' },
    },
    html_language_server = {
        name = 'html',
        binary_path = 'vscode-html-language-server',
        filetype = { 'html' },
    },
    css_language_server = {
        name = 'cssls',
        binary_path = 'vscode-css-language-server',
        filetype = { 'css', 'scss', 'less' },
    },
    js_language_server = {
        name = 'tsserver',
        binary_path = 'typescript-language-server',
        filetype = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    },
}

-- Get configuration from config module
local config_module = require('lsp.config')
local config = config_module.get_config(servers)

-- Check if binary exists in PATH
local function binary_exists(binary)
    return vim.fn.executable(binary) == 1
end

-- Validate server configuration
local function validate_server(server_config)
    if not binary_exists(server_config.binary_path) then
        return false, "Binary '" .. server_config.binary_path .. "' not found in PATH"
    end

    return true, "OK"
end

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

    local setup_count = 0
    local failed_servers = {}

    -- Setup each server
    for name, server_config in pairs(servers) do
        local ok, msg = validate_server(server_config)

        if ok then
            -- Set the LSP configuration
            local lsp_name = server_config.name
            vim.lsp.config[lsp_name] = config[name]

            -- Enable the LSP server
            vim.lsp.enable(lsp_name)

            setup_count = setup_count + 1
        else
            failed_servers[name] = msg
        end
    end

    -- Report setup results
    --if setup_count > 0 then
    --    vim.notify(string.format("[LSP] Successfully enabled %d server(s)", setup_count), vim.log.levels.INFO)
    --end

    if next(failed_servers) then
        vim.notify("[LSP] Some servers failed to start. Run :checkhealth lsp for details", vim.log.levels.WARN)
    end

    vim.api.nvim_create_user_command("LSPList", M.list, {})
end

-- Health check function
function M.health()
    vim.health.start("LSP Plugin Health")

    -- Check if LSP system is available
    if vim.lsp.config then
        vim.health.ok("LSP config system available")
    else
        vim.health.error("LSP config system not available")
    end

    -- Check each configured server
    for name, server_config in pairs(servers) do
        local ok, msg = validate_server(server_config)
        if ok then
            vim.health.ok(string.format("%s (%s): %s", name, server_config.name, msg))
        else
            vim.health.error(string.format("%s (%s): %s", name, server_config.name, msg))
        end
    end

    -- Check if any LSP clients are running
    local clients = vim.lsp.get_clients()
    if #clients > 0 then
        vim.health.ok(string.format("%d LSP client(s) running", #clients))
        for _, client in ipairs(clients) do
            vim.health.info(string.format("  - %s (id: %d)", client.name, client.id))
        end
    else
        vim.health.warn("No LSP clients currently running")
    end
end

function M.list()
    local installed = {}
    local running = {}
    local language = {}

    for name, server in pairs(servers) do
        table.insert(installed, server.name)
        language[server.name] = name:match('^[^_]+')
    end

    -- collect running clients
    for _, client in pairs(vim.lsp.get_clients()) do
        running[client.name] = true
    end

    -- build message
    local lines = {}
    for _, server in ipairs(installed) do
        local status = running[server] and "Running" or ""
        local lang = language[server]
        table.insert(lines, string.format("%s (%s) %s", server, lang, status))
    end
    table.sort(lines)

    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LSP Servers" })
end

return M
