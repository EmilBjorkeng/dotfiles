local menu = require('scout.menu')

local M = {}

local ns_id = vim.api.nvim_create_namespace("ScoutResultHL")
M.start_in_search = false

local function levenshtein(a, b)
    local len_a = #a
    local len_b = #b

    local dp = {}
    for i = 0, len_a do
        dp[i] = {}
        for j = 0, len_b do
            dp[i][j] = 0
        end
    end

    -- Base cases
    for i = 0, len_a do
        dp[i][0] = i  -- delete all characters from a
    end
    for j = 0, len_b do
        dp[0][j] = j  -- insert all characters of b
    end

    -- Fill the table
    for i = 1, len_a do
        for j = 1, len_b do
            local cost = (a:sub(i,i) == b:sub(j,j)) and 0 or 1
            dp[i][j] = math.min(
                dp[i-1][j] + 1,        -- Deletion
                dp[i][j-1] + 1,        -- Insertion
                dp[i-1][j-1] + cost    -- Substitution
            )
        end
    end

    return dp[len_a][len_b] -- Return the last value
end

local function fuzzy_string_match(query, path)
    local query_lower = query:lower()
    local max_dist = 1      -- Tolerance for the fuzzy check
    local min_query_len = 2 -- Minimum length the query has to be to be checked

    local path_trim = path:match("^%s*(.-)%s*$")
    local parts = vim.split(path_trim, '/')

    local col = 1
    local matches = {}

    for _, part in ipairs(parts) do
        local part_lower = part:lower()

        if part ~= '.' and part ~= '' then

            -- Substring match
            local start_index, end_index = part_lower:find(query_lower, 1, true)
            if start_index then
                table.insert(matches, {col + start_index - 1, col + end_index - 1})
                goto continue
            end

            -- Skip short queries to not get that a single letter
            -- matches with every query
            if #query_lower < min_query_len then
                goto continue
            end

            -- Sliding fuzzy matcher
            for i = 1, #part_lower - #query_lower + 1 do
                local substring = part_lower:sub(i, i + #query_lower - 1)
                if levenshtein(query_lower, substring) <= max_dist then
                    table.insert(matches, {col + i - 1, col + i + #query_lower - 2})
                    break
                end
            end
        end
        ::continue::
        col = col + #part + 1  -- Add 1 for the '/'
    end

    return matches
end

function M.scout_files()
    menu.open_menu({

    -- Result
    function(buf, bufs)
        vim.bo[buf].modifiable = true

        -- Get the files
        local entries = vim.fn.globpath('.', '**/*', false, true)
        local files = {}
        for _, path in ipairs(entries) do
            if vim.fn.isdirectory(path) == 0 then
                table.insert(files, '  ' .. path)
            end
        end

        local fuzzy_files = {}
        local highlights = {}
        local search = vim.api.nvim_buf_get_lines(bufs[2], 0, 1, false)[1]:sub(3)

        -- Fuzzy sort
        if search ~= '' then
            for _, file in ipairs(files) do
                local finds = fuzzy_string_match(search, file)
                if #finds >= 1 then
                    table.insert(fuzzy_files, file)
                    table.insert(highlights, finds)
                end
            end
        else
            -- No search
            fuzzy_files = files
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, fuzzy_files)

        -- Highlight fuzzy found words
        for line, matches in ipairs(highlights) do
            local buf_line = fuzzy_files[line] or ''
            for _, match in ipairs(matches) do
                -- Add 1 to compinsate for the spacing at the front of the result listing
                local start_col = match[1] + 1
                local end_col = math.min(match[2] + 2, #buf_line)
                vim.api.nvim_buf_set_extmark(buf, ns_id, line - 1, start_col, {
                    end_col = end_col,
                    hl_group = 'ScoutHL'
                })
            end
        end

        vim.bo[buf].modifiable = false
    end,

    -- Preview
    function(buf, bufs, cursor_pos)
        vim.bo[buf].modifiable = true
        -- Get content
        local line = vim.api.nvim_buf_get_lines(bufs[1], cursor_pos, cursor_pos + 1, false)[1]
        if not line then return end

        local path = line:sub(3)
        if path == '' then return end

        local lines = vim.fn.readfile(path)

        -- Syntax
        local ft = vim.filetype.match({ filename = path })
        vim.bo[buf].filetype = ft

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
    end,

    -- Run
    function(bufs, cursor_pos)
        local line = vim.api.nvim_buf_get_lines(bufs[1], cursor_pos, cursor_pos + 1, false)[1]
        if not line then return end

        local path = line:sub(3)
        if path == '' then return end

        vim.cmd('stopinsert')
        require('scout.menu').close_menu()
        vim.cmd("edit " .. vim.fn.fnameescape(path))
    end,

    })

    if M.start_in_search then
        -- Start in the search bar
        require('scout.menu').start_search()
    end
end

function M.scout_grep()
    menu.open_menu({

    -- Result
    function(buf)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'This is buffer 1' })
    end,

    -- Preview
    function(buf)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'This is buffer 3' })
    end,

    -- Run
    function()

    end,

    })
end

return M
