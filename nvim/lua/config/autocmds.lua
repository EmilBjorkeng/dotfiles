local group = vim.api.nvim_create_augroup('UserAutocmds', { clear = true })

-- Briefly highlight yanked text
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
        -- Commit messages should always start at the top
        if vim.bo[args.buf].filetype == 'gitcommit' then return end

        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Spellcheck in type focused filetypes
vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = { 'markdown', 'gitcommit', 'text' },
    callback = function()
        vim.opt_local.spell = true
    end,
})
