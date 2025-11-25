local local_plugins = vim.fn.stdpath('config') .. '/lua/'

return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
            { 'hrsh7th/cmp-nvim-lsp' },
        },
        config = function()
            require('config.mason')
            require('config.lsp').setup()
        end,
    },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
        },
        config = function()
            require('config.cmp')
        end,
    },
    {
        'rafamadriz/friendly-snippets'
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { 'BufReadPost', 'BufNewFile' },
        dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
        config = function()
            require('config.treesitter')
        end,
    },
    {
        dir = local_plugins .. 'line-comment',
        name = 'line-comment',
        event = 'BufReadPost',
        config = function()
            require('line-comment').setup()
        end,
    },
        {
        dir = local_plugins .. 'hexcolor',
        name = 'hexcolor',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = {
            autoshow = true,
        },
        config = function(_, opts)
            require('hexcolor').setup(opts)
        end,
    },
        {
        dir = local_plugins .. 'git-status',
        name = 'git-status',
        event = 'BufReadPost',
    },
        {
        dir = local_plugins .. 'hidden-tabs',
        name = 'hidden-tabs',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = {
            autoshow = true,
        },
        config = function(_, opts)
            require('hidden-tabs').setup(opts)
        end,
    },
        {
        dir = local_plugins .. 'greeter',
        name = 'greeter',
        config = function()
            require('greeter').setup()
        end,
        dependencies = { 'scout' },
    },
    {
        dir = local_plugins .. 'scout',
        name = 'scout',
        opts = {
            start_in_search = true,
        },
        config = function(_, opts)
            require('scout').setup(opts)
        end,
    },
        {
        dir = local_plugins .. 'end-hl-lua',
        name = 'end-hl-lua',
        ft = 'lua',
        config = function()
            require('end-hl-lua').setup()
        end,
    },
}

