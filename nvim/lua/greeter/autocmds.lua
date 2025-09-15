local M = {}

function M.setup(buf)
    vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = function()
        vim.api.nvim_win_set_cursor(0, {1, 0})
    end,
})
end

return M
