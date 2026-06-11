require('mason').setup()

local ensure_installed = {
    'lua-language-server', 'clangd', 'pyright',
    'rust-analyzer', 'html-lsp', 'css-lsp',
    'typescript-language-server', 'json-lsp',
    'bash-language-server', 'marksman',
}

local registry = require('mason-registry')

registry.refresh(function()
    for _, name in ipairs(ensure_installed) do
        local pkg = registry.get_package(name)
        if not pkg:is_installed() then
            pkg:install()
        end
    end
end)
