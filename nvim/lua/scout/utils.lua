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

return M
