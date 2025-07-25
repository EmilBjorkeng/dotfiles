local M = {}

-- Plugin setup
function M.setup()
    vim.keymap.set({'n', 'i'}, "<C-_>", ':lua require("line-comment").toggle_comment()<CR>', { silent = true })
end

-- Toggle the comment
function M.toggle_comment()
    -- Get current line and exit if it's empty
	local current_line = vim.api.nvim_get_current_line()
	if current_line == '' then return end

    -- Get the filetype from the filename
    -- And return if there is none
	local filename = vim.api.nvim_buf_get_name(0)
    if filename == '' then
        print('No filetype to get comment character from')
        -- TODO: Add prompt to type in comment character
        return
    end

    local filetype = string.lower(string.sub(
        filename,
        string.len(filename)-string.find(string.reverse(filename),'%.')+2,
        string.len(filename)
    ))
    print(filename)

    -- Use the (single/multi)_comment_chars tables to get the comment character based on the filetype
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

    -- Find the single line character based on filetype
    -- or leave it blank if there is nonee
    local single_comment_char = ''
    for k,v in pairs(single_comment_chars) do
		if k == filetype then
            single_comment_char = v
        end
    end
    -- Find the multi line character based on filetype
    -- or leave it blank if there is nonee
    local multi_comment_char = ''
    for k,v in pairs(multi_comment_chars) do
		if k == filetype then
            multi_comment_char = v
        end
    end

    -- Check if there is any single line comment
    if single_comment_char ~= '' then
        M.single_line_comment(current_line, single_comment_char)
        return
    end
    -- Check if there is any multi line comment
    if multi_comment_char ~= '' then
        M.multi_line_comment(current_line, multi_comment_char)
        return
    end

    -- If it can't find any
	print("Coun't find the comment character based on filetype")
end

-- For all the standard single line comments
function M.single_line_comment(current_line, comment_char)

    -- Add padding to the comment char
    comment_char = comment_char .. ' '

    -- Get the first nonee space character and exit if it can't find any
    local first_none_space = 0
    for i = 1, string.len(current_line), 1 do
        local char = string.sub(current_line,i,i)
        if char ~= ' ' then
            first_none_space = i
            break
        end
    end
    if first_none_space == 0 then return end

    -- Check if the line is comment out or not
    if string.sub(
        current_line,
        first_none_space,
        first_none_space+string.len(comment_char)-1
    ) == comment_char then

        -- Remove the comment character
		vim.api.nvim_set_current_line(
            string.sub(current_line,1,first_none_space-1) ..
            string.sub(
                current_line,
                first_none_space+string.len(comment_char),
                string.len(current_line)
            )
        )
    else
        -- Add the comment character
		vim.api.nvim_set_current_line(
            string.sub(current_line,1,first_none_space-1) ..
            comment_char ..
            string.sub(current_line,first_none_space,string.len(current_line))
        )
	end
end

-- For the multi line comments
function M.multi_line_comment(current_line, comment_char)

    -- Split the two parts of the comment char and add padding to them
    local split_comment_char = string_split(comment_char)
    split_comment_char[1] = split_comment_char[1] .. ' '
    split_comment_char[2] = ' ' .. split_comment_char[2]

    -- Get the first nonee space character and exit if it can't find any
    local first_none_space = 0
    for i = 1, string.len(current_line), 1 do
        local char = string.sub(current_line,i,i)
        if char ~= ' ' then
            first_none_space = i
        end
    end
    if first_none_space == 0 then return end

    -- True if the first part of the comment chars is there
    local first_part = string.sub(current_line,
        first_none_space,
        first_none_space+string.len(split_comment_char[1])-1
    ) == split_comment_char[1]

    -- True if the secound part of the comment chars is there
    local secound_part = string.sub(current_line,
        string.len(current_line)-string.len(split_comment_char[2])+1,
        string.len(current_line)
    ) == split_comment_char[2]

    -- Check if the line is comment out
    if first_part and secound_part then

        -- Remove the comment character
        -- Remove the comment character
		vim.api.nvim_set_current_line(
            string.sub(current_line,1,first_none_space-1) ..
            string.sub(
                current_line,
                first_none_space+string.len(split_comment_char[1]),
                string.len(current_line)-string.len(split_comment_char[2])
            )
        )

    -- Check if there is not the first or secound part there 
    -- Because if there is one of them but not both do nothing
    elseif not first_part and not secound_part then

        -- Add the comment character
		vim.api.nvim_set_current_line(
            string.sub(current_line,1,first_none_space-1) ..
            split_comment_char[1] ..
            string.sub(current_line,first_none_space,string.len(current_line))
            .. split_comment_char[2]
        )
    end
end

return M
