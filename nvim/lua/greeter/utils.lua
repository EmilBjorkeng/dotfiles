local M = {}

M.ascii = {
    [[                                                                       ]],
    [[                                                                     ]],
    [[       ████ ██████           █████      ██                     ]],
    [[      ███████████             █████                             ]],
    [[      █████████ ███████████████████ ███   ███████████   ]],
    [[     █████████  ███    █████████████ █████ ██████████████   ]],
    [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
    [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
    [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
    [[                                                                       ]],
}

function M.table_append(list, append)
    for i = 1, #append do
        list[#list + 1] = append[i]
    end
end

function M.combine_lines(lines1, lines2)
    for i = 1, #lines2 do
        lines1[#lines1 + 1] = lines2[i]
    end
    return lines1
end

function M.center_block(lines)
    local win_width = vim.api.nvim_win_get_width(0)

    local max_len = 0
    for _, line in ipairs(lines) do
        local disp_len = vim.fn.strdisplaywidth(line)
        if disp_len > max_len then
            max_len = disp_len
        end
    end

    local padding = math.floor((win_width - max_len) / 2)
    if padding < 0 then padding = 0 end

    local padded = {}
    for i, line in ipairs(lines) do
        padded[i] = string.rep(" ", padding) .. line
    end

    return padded, padding
end

function M.spacing(num)
    local list = {}
    for _ = 0, num do
        table.insert(list, "")
    end
    return list
end

return M
