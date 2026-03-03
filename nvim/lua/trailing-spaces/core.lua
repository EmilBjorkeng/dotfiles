local M = {}

local ns_id = vim.api.nvim_create_namespace("TrailingSpaces")

M.enabled = false

function M.toggle()
    if not M.enabled then
        M.enabled = true
        M.refresh()
        vim.notify("Trailing spaces highlighting enabled")
    else
        M.enabled = false
        M.refresh()
        print("Trailing spaces highlighting disabled")
    end
end

function M.highlight_trailing_spaces(bufnr)
    for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
        local s, e = line:find("%s+$")
        if s and e then
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, s - 1, {
                end_row = i - 1,
                end_col = e,
                hl_group = "TrailingSpaces",
            })
        end
    end
end

function M.refresh()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    if not M.enabled then return end

    if vim.api.nvim_get_option_value("modifiable", { buf = bufnr }) then
        M.highlight_trailing_spaces(bufnr)
    end
end

function M.remove_trailing_spaces()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_get_option_value("modifiable", { buf = bufnr }) then
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
