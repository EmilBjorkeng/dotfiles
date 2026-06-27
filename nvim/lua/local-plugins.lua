local dev_path = vim.fn.stdpath('config') .. '/dev/'

return {
    {
        dir = dev_path .. 'line-comment',
        name = 'line-comment',
        event = 'BufReadPost',
        config = function()
            require('line-comment').setup()
        end,
    },
    {
        dir = dev_path .. 'hexcolor',
        name = 'hexcolor',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = {
            autoshow = true
        },
        config = function(_, opts)
            require('hexcolor').setup(opts)
        end,
    },
    {
        dir = dev_path .. 'git-status',
        name = 'git-status',
        event = 'BufReadPost',
        opts = {
            autoshow = true
        },
        config = function(_, opts)
            require('git-status').setup(opts)
        end,
    },
    {
        dir = dev_path .. 'hidden-tabs',
        name = 'hidden-tabs',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = {
            autoshow = true
        },
        config = function(_, opts)
            require('hidden-tabs').setup(opts)
        end,
    },
    {
        dir = dev_path .. 'trailing-spaces',
        name = 'trailing-spaces',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = {
            autoshow = true
        },
        config = function(_, opts)
            require('trailing-spaces').setup(opts)
        end,
    },
    {
        dir = dev_path .. 'scout',
        name = 'scout',
        opts = {
            start_in_search = true,
        },
        config = function(_, opts)
            require('scout').setup(opts)
        end,
    },
    {
        dir = dev_path .. 'greeter',
        name = 'greeter',
        dependencies = { 'scout' },
        config = function()
            require('greeter').setup()
        end,
    },
    {
        dir = dev_path .. 'end-hl-lua',
        name = 'end-hl-lua',
        ft = 'lua',
        config = function()
            require('end-hl-lua').setup()
        end,
    },
}
