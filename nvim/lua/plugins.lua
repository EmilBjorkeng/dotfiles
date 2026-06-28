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
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("config.treesitter").setup()
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "VeryLazy",
        config = function()
            require("config.treesitter-textobjects").setup()
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("config.autotag").setup()
        end,
    },
    {
        'HiPhish/rainbow-delimiters.nvim',
        event = { 'BufReadPost', 'BufNewFile' },
        config = function()
            require('rainbow-delimiters.setup').setup({
                highlight = {
                    'RainbowDelimiterYellow',
                    'RainbowDelimiterViolet',
                    'RainbowDelimiterRed',
                    'RainbowDelimiterBlue',
                    'RainbowDelimiterGreen',
                    'RainbowDelimiterOrange',
                    'RainbowDelimiterCyan',
                },
            })
        end,
    },
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        dependencies = { 'hrsh7th/nvim-cmp' },
        config = function()
            require('nvim-autopairs').setup({
                check_ts = true,
            })
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end,
    },
    {
        'tpope/vim-sleuth',
    },
}
