return {
    {
        module = 'line-comment',
        lazy = { event = 'BufReadPost' },
        config = true,
    },
    {
        module = 'trailing-spaces',
        lazy = { event = { 'BufReadPost', 'BufNewFile' } },
        config = false,
    },
    {
        module = 'filemenu',
        lazy = { cmd = 'File' },
        config = true,
    },
    {
        module = 'lsp',
        lazy = { ft = {
            'lua', 'c', 'cpp', 'objc', 'objcpp',
            'python', 'rust',
            'html', 'css', 'scss', 'less',
            'javascript', 'typescript'
        }},
        config = true,
        dependencies = { 'lspconfig' }
    },
    {
        module = 'lspconfig',
        repo = 'neovim/nvim-lspconfig',
        config = false,
    },
    {
        module = 'hexcolor',
        lazy = { event = { 'BufReadPost', 'BufNewFile' } },
        config = function(plugin)
            require(plugin.module).setup({
                autoshow = true,
            })
        end,
    },
    {
        module = 'git-status',
        lazy = { event = { 'BufReadPost', 'BufNewFile' } },
        config = function(plugin)
            require(plugin.module).setup({
                autoshow = true,
            })
        end,
    },
    {
        module = 'hidden-tabs',
        lazy = { event = { 'BufReadPost', 'BufNewFile' } },
        config = function(plugin)
            require(plugin.module).setup({
                autoshow = true,
            })
        end,
    },
    {
        module = 'greeter',
        config = true,
        dependencies = { 'scout' },
    },
    {
        module = 'scout',
        config = function(plugin)
            require(plugin.module).setup({
                start_in_search = true,
            })
        end,
    },
    {
        module = 'end-hl-lua',
        lazy = { ft = { 'lua' } },
        config = true,
    },
}
