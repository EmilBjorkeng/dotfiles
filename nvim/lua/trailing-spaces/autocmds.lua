local M = {}

function M.setup()
    vim.cmd [[highlight TrailingWhitespace ctermbg=red guibg=red]]
    vim.cmd([[
        augroup TrailingSpaces
        autocmd!
        autocmd BufEnter,BufWritePost,TextChanged,TextChangedI * lua require('trailing-spaces.core').refresh()
        augroup END
    ]])
end

return M
