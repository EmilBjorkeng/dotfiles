return {
    {
        name = 'Line Comment',
        module = 'line-comment',
        lazy = { event = 'BufReadPost' },
        config = true,
    },
    {
        name = 'Trailing Spaces',
        module = 'trailing-spaces',
        lazy = { event = { 'BufReadPost', 'BufNewFile' } },
        config = true,
    },
    {
        name = 'Filemenu',
        module = 'filemenu',
        lazy = { cmd = 'File' },
        config = true,
    },
    {
        name = 'LSP',
        module = 'lsp',
        lazy = { ft = {
            'lua', 'c', 'cpp', 'objc', 'objcpp',
            'python', 'rust',
            'html', 'css', 'scss', 'less',
            'javascript', 'typescript'
        }},
        config = true,
    },
    {
        name = 'Hexcolor',
        module = 'hexcolor',
        lazy = { event = { 'BufReadPost', 'BufNewFile' } },
        config = function(plugin)
            require(plugin.module).setup({
                autoshow = true,
            })
        end,
    },
    {
        name = 'Git status',
        module = 'git-status',
        lazy = { event = { 'BufReadPost', 'BufNewFile' } },
        config = function(plugin)
            require(plugin.module).setup({
                autoshow = true,
            })
        end,
    },
    {
        name = 'Hidden Tabs',
        module = 'hidden-tabs',
        lazy = { event = { 'BufReadPost', 'BufNewFile' } },
        config = function(plugin)
            require(plugin.module).setup({
                autoshow = true,
            })
        end,
    },
    {
        name = 'Greeter',
        module = 'greeter',
        config = true,
        dependencies = { 'filemenu' },
    },
}
