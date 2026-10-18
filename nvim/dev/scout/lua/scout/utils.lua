local M = {}

function M.shallow_copy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = v
    end
    return copy
end

function M.table_comb(t1, t2)
    local res = {}
    for k, v in pairs(t1) do
        res[k] = v
    end
    for k, v in pairs(t2) do
        res[k] = v
    end
    return res
end

function M.index_of(tbl, n)
    for i, v in ipairs(tbl) do
        if v == n then
            return i
        end
    end
    return nil -- not found
end

-- Delete a buffer without closing the windows that display it
function M.delete_buffer(bufnr)
    if vim.bo[bufnr].modified then
        vim.notify('Unsaved changes in ' .. vim.fn.bufname(bufnr), vim.log.levels.WARN)
        return false
    end

    for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        vim.api.nvim_win_call(win, function()
            -- The alternate buffer is per window, so this picks each window's own '#'
            local alt = vim.fn.bufnr('#')
            if alt > 0 and alt ~= bufnr and vim.fn.buflisted(alt) == 1 then
                vim.cmd('buffer ' .. alt)
            else
                vim.cmd('bprevious')
            end
            -- Only one listed buffer existed, so fall back to an empty one
            if vim.api.nvim_get_current_buf() == bufnr then
                vim.cmd('enew')
            end
        end)
    end

    return pcall(vim.api.nvim_buf_delete, bufnr, {})
end

return M
