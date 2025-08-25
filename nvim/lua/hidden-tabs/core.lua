local M = {}

local ns_id = vim.api.nvim_create_namespace("HiddenTabs")

local function highlight_tabs(bufnr)
    for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
        local pos = 1
        while true do
            local s, e = line:find("\t", pos)
            if not s then break end
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, s - 1, {
                end_row = i - 1,
                end_col = e,
                hl_group = "HiddenTabs",
            })
            pos = e + 1
        end
    end
end

function M.refresh()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_get_option_value("modifiable", { buf = bufnr }) then
        highlight_tabs(bufnr)
    end
end

function M.tabs_to_spaces()
    local cursor = vim.api.nvim_win_get_cursor(0)

    local tabstop = vim.bo.tabstop
    local spaces = string.rep(' ', tabstop)

    local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
    local _, tab_count = string.gsub(content, '\t', '')


    vim.cmd('silent! %s/\t/' .. spaces .. '/g')

    vim.api.nvim_win_set_cursor(0, cursor)

    vim.notify('Converted ' .. tab_count ..
        ' tab' .. (tab_count == 0 and '' or 's') ..
        ' into spaces (tabstop=' .. tabstop .. ')')
end

return M
