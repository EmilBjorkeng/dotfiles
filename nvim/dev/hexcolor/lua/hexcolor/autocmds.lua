local M = {}

function M.setup()
    vim.cmd([[
        augroup HexcolorHighlight
        autocmd!
        autocmd BufEnter,BufWritePost,TextChanged,TextChangedI * lua require('hexcolor.core').refresh()
        augroup END
    ]])
end

return M
