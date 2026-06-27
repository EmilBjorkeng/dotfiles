local dev_path = vim.fn.stdpath('config') .. '/lua/'

return {
    {
        'williamboman/mason.nvim',
        config = function()
            require('config.mason')
            require('config.lsp').setup()
        end,
    },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            {
                'L3MON4D3/LuaSnip',
                dependencies = { 'rafamadriz/friendly-snippets' },
            },
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
        },
        config = function()
            require('config.cmp')
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { 'BufReadPost', 'BufNewFile' },
        dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
        config = function()
            require('nvim-treesitter').setup({
                ensure_installed = {
                    'lua', 'c', 'python', 'javascript', 'html', 'css',
                    'bash', 'regex', 'printf', 'markdown', 'json',
                    'typescript', 'glsl', 'rust',
                },
                highlight = { enable = true },
            })
        end,
    },
}
