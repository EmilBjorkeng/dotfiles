return {
    {
        module = 'line-comment',
        lazy = { event = 'BufReadPost' },
        config = true,
    },
    {
        module = 'lsp',
        lazy = { event = 'BufReadPost' },
        config = true,
        dependencies = {
            {
                repo = 'neovim/nvim-lspconfig',
                name = 'lspconfig'
            },
        }
    },
    {
        module = 'hexcolor',
        lazy = { event = { 'BufReadPost', 'BufNewFile' } },
        opts = {
            autoshow = true,
        },
        config = function(plugin)
            require(plugin.module).setup(plugin.opts)
        end,
    },
    {
        module = 'git-status',
        lazy = { event = { 'BufReadPost' } },
    },
    {
        module = 'hidden-tabs',
        lazy = { event = { 'BufReadPost', 'BufNewFile' } },
        opts = {
            autoshow = true,
        },
        config = function(plugin)
            require(plugin.module).setup(plugin.opts)
        end,
    },
    {
        module = 'greeter',
        config = true,
        dependencies = { 'scout' },
    },
    {
        module = 'scout',
        opts = {
            start_in_search = true,
        },
        config = function(plugin)
            require(plugin.module).setup(plugin.opts)
        end,
    },
    {
        module = 'end-hl-lua',
        lazy = { ft = { 'lua' } },
        config = true,
    },
    {
        repo = 'hrsh7th/nvim-cmp',
        name = 'cmp',
        config = false,
        before_deps = true,
        dependencies = {
            {
                repo = 'neovim/nvim-lspconfig',
                name = 'lspconfig'
            },
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',

        },
    },
}
