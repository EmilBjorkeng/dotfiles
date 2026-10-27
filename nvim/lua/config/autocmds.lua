local group = vim.api.nvim_create_augroup('UserAutocmds', { clear = true })

-- Briefly highlight yanked text (requires Neovim 0.11+)
vim.api.nvim_create_autocmd('TextYankPost', {
    group = group,
    callback = function()
        vim.hl.on_yank({ higroup = 'Visual', timeout = 150 })
    end,
})

-- Reopen files at the last cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
    group = group,
    callback = function(args)
        -- Commit messages and rebase todos should always start at the top.
        -- Checked by filename because filetype isn't set yet at this point.
        local name = vim.fs.basename(args.file)
        if name == 'COMMIT_EDITMSG' or name == 'git-rebase-todo' then
            return
        end

        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Spellcheck and soft wrapping in text-focused filetypes
vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = { 'markdown', 'gitcommit', 'text' },
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
    end,
})

-- Relative line numbers only in normal mode and in the focused window
local number_group = vim.api.nvim_create_augroup('NumberToggle', { clear = true })

vim.api.nvim_create_autocmd({ 'InsertEnter', 'FocusLost', 'WinLeave' }, {
    group = number_group,
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = false
        end
    end,
})

vim.api.nvim_create_autocmd({ 'InsertLeave', 'FocusGained', 'WinEnter' }, {
    group = number_group,
    callback = function()
        if vim.wo.number and vim.fn.mode() ~= 'i' then
            vim.wo.relativenumber = true
        end
    end,
})

-- Absolute line numbers while typing a command
vim.api.nvim_create_autocmd('CmdlineEnter', {
    group = number_group,
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = false
            vim.cmd.redraw()
        end
    end,
})

vim.api.nvim_create_autocmd('CmdlineLeave', {
    group = number_group,
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = true
        end
    end,
})
