local M = {}

function M.setup()
    vim.cmd([[
        augroup HiddenTabs
        autocmd!
        autocmd BufEnter,BufWritePost,TextChanged,TextChangedI * lua require('hidden-tabs.core').refresh()
        augroup END
    ]])
end

return M
