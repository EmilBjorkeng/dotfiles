local M = {}

function M.get_first_none_space(line)
    local first_none_space = 0
    for i = 1, string.len(line), 1 do
        local char = string.sub(line,i,i)
        if char ~= ' ' then
            first_none_space = i
            break
        end
    end
    return first_none_space
end

function M.split_string(str)
    local result = {}
    for word in string.gmatch(str, "%S+") do
        table.insert(result, word)
    end
    return result
end

function M.get_filetype()
    local filename = vim.api.nvim_buf_get_name(0)
    if filename == '' then
        vim.notify('No filetype to get comment character from', vim.log.levels.WARN)
        return nil
    end

    local filetype = string.lower(string.sub(
        filename,
        string.len(filename)-string.find(string.reverse(filename),'%.')+2,
        string.len(filename)
    ))
    return filetype
end

return M
