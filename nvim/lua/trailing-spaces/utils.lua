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

    -- Remove Trailing Spaces
    vim.api.nvim_create_user_command("RTS",
        ':lua require("trailing-spaces").remove_trailing_spaces()<CR>',
        { desc = "Removes all current trailing spaces", })
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
            vim.api.nvim_buf_add_highlight(bufnr, ns_id, "TrailingWhitespace", i - 1, s - 1, e)
        end
    end
end

function M.remove_trailing_spaces()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_get_option(bufnr, "modifiable") then
        M.highlight_trailing_spaces(bufnr)
    end

    local count = 0
    for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
        local s, e = line:find("%s+$")
        if s and e then
            local crop_len = e - s + 1
            local new_line = string.sub(line, 0, #line - crop_len)
            vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { new_line })
            count = count + 1
        end
    end
    vim.notify("Removed " .. count .. " trailing space" .. (count == 1 and "" or "s"))
end

return M
