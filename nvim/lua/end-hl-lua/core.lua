local M = {}

local ns_id = vim.api.nvim_create_namespace("EndHighlight")

local function contains(tbl, str)
    for _, value in ipairs(tbl) do
        if value == str then
            return true
        end
    end
    return false
end

local words = {
    'function', 'if', 'for', 'while', 'elseif', 'else', 'do', 'then'
}

local depth_words = {
    'function', 'if', 'for', 'while'
}

local in_comment = false

local function strip_comments(str)
    local function replace_range(s, start_pos, end_pos)
        local len = end_pos - start_pos + 1
        return s:sub(1, start_pos - 1) .. string.rep(' ', len) .. s:sub(end_pos + 1)
    end

    if in_comment then
        local _, close_pos = str:find('%]%]')
        if close_pos then
            str = replace_range(str, 1, close_pos)
            in_comment = false
        else
            -- Whole line is commented out, return empty line
            return ''
        end
    end

    -- Replace comments with spaces
    while true do
        local open_pos = str:find('%-%-%[%[')
        if not open_pos then break end

        local close_pos = str:find('%]%]', open_pos + 4)
        if close_pos then
            str = replace_range(str, open_pos, close_pos + 3)
        else
            -- Multi line comment start with no end
            str = replace_range(str, open_pos, #str)
            in_comment = true
            break
        end
    end

    -- Replace single line comment
    local comment_pos = str:find('%-%-')
    if comment_pos then
        str = replace_range(str, comment_pos, #str)
    end

    return str
end

local function end_check(depth, str)
    str = strip_comments(str)

    local i = 1
    while i <= #str do
        -- skip spaces
        if str:sub(i,i):match('%s') then
            i = i + 1
        else
            -- Get word
            local j = i
            while j <= #str and str:sub(j,j):match('%S') do
                j = j + 1
            end
            local word = str:sub(i,j-1)

            -- Word check
            if word == 'end' then
                depth = depth - 1
            elseif contains(depth_words, word) then
                depth = depth + 1
            end

            if depth < 0 then
                return -i - 1
            end

            -- Next word
            i = j
        end
    end
    return depth
end

local function word_check(depth, str)
    str = strip_comments(str)

    local i = #str
    while i >= 1 do
        -- skip spaces
        if str:sub(i,i):match('%s') then
            i = i - 1
        else
            -- Get word
            local j = i
            while j >= 1 and str:sub(j,j):match('%S') do
                j = j - 1
            end
            local word = str:sub(j+1,i)

            -- Word check
            if contains(depth_words, word) then
                depth = depth - 1
            elseif word == 'end' then
                depth = depth + 1
            end

            if depth < 0 then
                return -i - 1, #word
            end

            -- Next word
            i = j
        end
    end
    return depth
end

local function is_in_comment(row, col)
    local bufnr = vim.api.nvim_get_current_buf()

    -- Current line
    local current_line = vim.api.nvim_get_current_line()
    local before_cursor = string.sub(current_line, 1, col):gsub("%s*%S+$", "")
    if string.find(before_cursor, "%-%-") then
        return true
    end

    -- Check for comment start above
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, row - 1, false)
    local i = #lines
    for i = #lines, 1, -1 do
        local line = lines[i]

        local open_pos = line:find('%-%-%[%[')
        local close_pos = line:find('%]%]')

        if close_pos then
            if open_pos then
                -- Both open and closing tags found

                if open_pos < close_pos then
                    -- If the closing pos is after the open pos
                    -- then the cursor is not in a comment
                    return false
                else
                    -- If the closing pos is before the open pos
                    -- then the cursor is in a comment
                    return true
                end
            end

            -- Closing tag without a open tag
            -- then the cursor is not in a comment
            return false
        end

        if open_pos then
            -- If there is an open tag but no closing tag
            -- then the cursor is in a comment
            return true
        end
    end

    -- Fallback
    return false
end

function M.refresh()
    local bufnr = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_get_option_value("modifiable", { buf = bufnr }) then
        return
    end
    if vim.bo.filetype ~= 'lua' then return end

    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local current_line = vim.api.nvim_get_current_line()

    local from, _ = current_line:sub(1, col+1):find('%S*%S$')
    local _, to = current_line:sub(col+1, #current_line):find('^%S*%S')

    if (not (from and to)) then return end
    to = to + col

    local word = current_line:sub(from, to)

    if is_in_comment(row, col) then return end

    -- Word -> End (End HL)
    -- TODO: HL the elseif and else when selecting the if
    if contains(words, word) then
        -- Highlight the selected word
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, from - 1, {
            end_col = to,
            hl_group = 'MatchParen',
        })

        -- Check for end on current line
        local after_cursor = string.sub(current_line, col+1):gsub("^%S+%s*", "")
        local depth = end_check(0, after_cursor)
        if depth < 0 then
            local word_col = -depth + to - 1
            -- Highlight the end (Same line)
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, word_col, {
                end_col = word_col + 3,
                hl_group = 'MatchParen',
            })
            return
        end

        -- Check for end on lines bellow
        local lines = vim.api.nvim_buf_get_lines(bufnr, row, -1, false)
        for i, line in ipairs(lines) do
            local line_num = row + i

            depth = end_check(depth, line)
            if depth < 0 then
                local word_col = -depth - 2
                -- Highlight the end (Different line)
                vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num - 1, word_col, {
                    end_col = word_col + 3,
                    hl_group = 'MatchParen',
                })
                return
            end
        end

    -- End -> Word (Word HL)
    elseif word == 'end' then
        -- Highlight the selected end
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, from - 1, {
            end_col = to,
            hl_group = 'MatchParen',
        })

        -- Check for word on current line
        local before_cursor = string.sub(current_line, 1, col):gsub("%s*%S+$", "")
        local depth, word_len = word_check(0, before_cursor)
        if depth < 0 then
            local word_col = -depth - 1 - word_len
            -- Highlight the end (Same line)
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, word_col, {
                end_col = word_col + word_len,
                hl_group = 'MatchParen',
            })
            return
        end

        -- Check for end on lines above
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, row - 1, false)
        for i = #lines, 1, -1 do
            local line = lines[i]
            local line_num = i

            depth, word_len = word_check(depth, line)
            if depth < 0 then
                local word_col = -depth - 1
                -- Highlight the word (Different line)
                vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num - 1, word_col - word_len, {
                    end_col = word_col,
                    hl_group = 'MatchParen',
                })
                return
            end
        end
    end
end

return M
