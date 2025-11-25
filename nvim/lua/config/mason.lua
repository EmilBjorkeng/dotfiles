require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = {
        'lua_ls', 'clangd', 'pyright',
        'rust_analyzer', 'html','cssls',
        'ts_ls', 'jsonls', 'bashls',
        'marksman',
    },
})

