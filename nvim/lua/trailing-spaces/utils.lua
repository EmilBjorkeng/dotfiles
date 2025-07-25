local M = {}

local ns_id = vim.api.nvim_create_namespace("TrailingSpaces")

function M.setup()
    vim.cmd [[highlight TrailingWhitespace ctermbg=red guibg=red]]
    vim.cmd([[
        augroup TrailingSpaces
        autocmd!
        autocmd BufEnter,BufWritePost,TextChanged,TextChangedI * lua require('trailing-spaces').refresh()
        augroup END
    ]])
end

function M.refresh()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_get_option(bufnr, "modifiable") then
        M.highlight_trailing_spaces(bufnr)
    end
end

function M.highlight_trailing_spaces(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
        local s, e = line:find("%s+$")
        if s and e then
            -- i - 1 because nvim_buf_add_highlight uses 0-based indexing
            vim.api.nvim_buf_add_highlight(bufnr, ns_id, "TrailingWhitespace", i - 1, s - 1, e)
        end
    end
end

return M
