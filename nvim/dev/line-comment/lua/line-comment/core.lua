local utils = require('line-comment.utils')

local M = {}

local single_comment_chars = {
    c='//',h='//',cpp='//',hpp='//',java='//',
    js='//',php='//',swift='//',go='//',rs='//',
    kt='//',scala='//',ts='//',py='#',rb='#',
    pl='#',sh='#',lua='--',sql='--',asm=';'
}
local multi_comment_chars = {
    css='/* */',
    html='<!-- -->'
}

local function add_single_comment(line, first_none_space, comment_char)
    return string.sub(line,0,first_none_space-1) ..
        comment_char ..
        string.sub(
            line,
            first_none_space,
            string.len(line)
        )
end

local function remove_single_comment(line, first_none_space, comment_char)
    return string.sub(line,1,first_none_space-1) ..
        string.sub(
            line,
            first_none_space+string.len(comment_char),
            string.len(line)
        )
end

local function add_multi_comment(line, first_none_space, split_comment_char)
    return string.sub(line,0,first_none_space-1) ..
        split_comment_char[1] ..
        string.sub(line,first_none_space,string.len(line)) ..
        split_comment_char[2]
end

local function remove_multi_comment(line, first_none_space, split_comment_char)
    return string.sub(line,1,first_none_space-1) ..
    string.sub(
        line,
        first_none_space+string.len(split_comment_char[1]),
        string.len(line)-string.len(split_comment_char[2])
    )
end

-- ------------
-- Line
------------
local function single_line_comment(current_line, comment_char)
    comment_char = comment_char .. ' '

    local first_none_space = utils.get_first_none_space(current_line)
    if first_none_space == 0 then return end

    -- Check if the line is comment out
    if string.sub(
        current_line,
        first_none_space,
        first_none_space+string.len(comment_char)-1
    ) == comment_char then
        vim.api.nvim_set_current_line(
            remove_single_comment(current_line, first_none_space, comment_char)
        )
    else
        vim.api.nvim_set_current_line(
            add_single_comment(current_line, first_none_space, comment_char)
        )
	end
end

local function multi_line_comment(current_line, comment_char)
    local split_comment_char = utils.split_string(comment_char)
    split_comment_char[1] = split_comment_char[1] .. ' '
    split_comment_char[2] = ' ' .. split_comment_char[2]

    local first_none_space = utils.get_first_none_space(current_line)
    if first_none_space == 0 then return end

    local first_part = string.sub(current_line,
        first_none_space,
        first_none_space+string.len(split_comment_char[1])-1
    ) == split_comment_char[1]

    local secound_part = string.sub(current_line,
        string.len(current_line)-string.len(split_comment_char[2])+1,
        string.len(current_line)
    ) == split_comment_char[2]

    -- Check if the line is comment out
    if first_part and secound_part then
        -- Remove comment
        vim.api.nvim_set_current_line(
            remove_multi_comment(current_line, first_none_space, split_comment_char)
        )
    elseif not first_part and not secound_part then
        -- Add comment
        vim.api.nvim_set_current_line(
            add_multi_comment(current_line, first_none_space, split_comment_char)
        )
    end
end

local function get_comment_char(filetype)
    -- Find the single line character based on filetype
    local single_comment_char = ''
    for k,v in pairs(single_comment_chars) do
		if k == filetype then
            single_comment_char = v
        end
    end
    -- Find the multi line character based on filetype
    local multi_comment_char = ''
    for k,v in pairs(multi_comment_chars) do
		if k == filetype then
            multi_comment_char = v
        end
    end
    return single_comment_char, multi_comment_char
end

function M.toggle_comment()
	local current_line = vim.api.nvim_get_current_line()
	if not current_line then return end

    local filetype = utils.get_filetype()
    if filetype == nil then return end
    local single_comment_char, multi_comment_char = get_comment_char(filetype)

    if single_comment_char ~= '' then
        single_line_comment(current_line, single_comment_char)
        return
    end
    if multi_comment_char ~= '' then
        multi_line_comment(current_line, multi_comment_char)
        return
    end

    vim.notify('Could not find the comment character based on filetype', vim.log.levels.WARN)
end

------------
-- Section
------------
local function section_commented_single(lines, comment_char)
    local result = true
    for _,line in pairs(lines) do
        local first_none_space = utils.get_first_none_space(line)
        if first_none_space == 0 then goto continue end
        if string.sub(
            line,
            first_none_space,
            first_none_space+string.len(comment_char)-1
        ) ~= comment_char then
            result = false
        end
        ::continue::
    end
    return result
end

local function section_single_comment(lines, section, comment_char)
    comment_char = comment_char .. ' '
    local commented = section_commented_single(lines, comment_char)

    for i = 1, #lines do
        local first_none_space = utils.get_first_none_space(lines[i])
        if first_none_space == 0 then goto continue end

        if commented then
            lines[i] =
                remove_single_comment(lines[i], first_none_space, comment_char)
        else
            lines[i] =
                add_single_comment(lines[i], first_none_space, comment_char)
        end
        ::continue::
    end

    vim.api.nvim_buf_set_lines(0, section[1], section[2], false, lines)
end

local function section_commented_multi(lines, split_comment_char)
    local result = true
    for _,line in pairs(lines) do
        local first_none_space = utils.get_first_none_space(line)
        if first_none_space == 0 then goto continue end
        local first_part = string.sub(line,
            first_none_space,
            first_none_space+string.len(split_comment_char[1])-1
        ) == split_comment_char[1]

        local secound_part = string.sub(line,
            string.len(line)-string.len(split_comment_char[2])+1,
            string.len(line)
        ) == split_comment_char[2]


        if not first_part and not secound_part then
            result = false
        end
        ::continue::
    end
    return result
end

local function section_multi_comment(lines, section, comment_char)
    local split_comment_char = utils.split_string(comment_char)
    split_comment_char[1] = split_comment_char[1] .. ' '
    split_comment_char[2] = ' ' .. split_comment_char[2]
    local commented = section_commented_multi(lines, split_comment_char)

    for i = 1, #lines do
        local first_none_space = utils.get_first_none_space(lines[i])
        if first_none_space == 0 then goto continue end

        if commented then
            lines[i] =
                remove_multi_comment(lines[i], first_none_space, split_comment_char)
        else
            lines[i] =
                add_multi_comment(lines[i], first_none_space, split_comment_char)
        end
        ::continue::
    end

    vim.api.nvim_buf_set_lines(0, section[1], section[2], false, lines)

end

function M.toggle_section(startline, endline)
    local filetype = utils.get_filetype()
    if filetype == nil then return end
    local single_comment_char, multi_comment_char = get_comment_char(filetype)

    local section = { startline-1, endline }
    local lines = vim.api.nvim_buf_get_lines(0, startline-1, endline, true)

    if single_comment_char ~= '' then
        section_single_comment(lines, section, single_comment_char)
        return
    end
    if multi_comment_char ~= '' then
        section_multi_comment(lines, section, multi_comment_char)
        return
    end

    vim.notify('Could not find the comment character based on filetype', vim.log.levels.WARN)
end

return M
