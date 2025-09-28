local menu = require('scout.menu')

local M = {}

local ns_id = vim.api.nvim_create_namespace('ScoutFilesHL')

local excluded_filetypes = {
    'png', 'jpg', 'jpeg', 'gif', 'bmp', 'ico', 'webp',
    'tiff', 'pdf', 'zip', 'tar', 'gz', 'xz', '7z',
    'rar', 'mp3', 'wav', 'flac', 'ogg', 'mp4', 'mkv',
    'avi', 'mov', 'webm', 'exe', 'dll', 'so', 'bin',
    'o', 'a', 'class',
}

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

function M.fuzzy_string_match(query, path)
    local query_lower = query:lower()
    local max_dist = 1      -- Tolerance for the fuzzy check
    local min_query_len = 3 -- Minimum length the query has to be to be fuzzy checked

    local path_lower = path:lower()
    local path_trim = path_lower:gsub('/', '')

    local matches = {}

    -- Maps the trimed path back to the original one
    local index_map = {}
    local stripped_idx = 1
    for i = 1, #path_lower do
        if path_lower:sub(i, i) ~= '/' then
            index_map[stripped_idx] = i
            stripped_idx = stripped_idx + 1
        end
    end

    -- Substring match (find all occurrences)
    local start = 1
    while true do
        local start_index, end_index = path_trim:find(query_lower, start, true)
        if not start_index then break end

        -- Map back to original path indices
        local orig_start = index_map[start_index]
        local orig_end = index_map[end_index]
        table.insert(matches, {orig_start, orig_end})

        start = end_index + 1
    end

    -- Skip to next part if we found at least one exact match
    if #matches > 0 then
        goto skip
    end

    -- Skip short queries to not get that a single letter
    -- matches with every query
    if #query_lower < min_query_len then
        goto skip
    end

    -- Sliding fuzzy matcher
    for i = 1, #path_trim - #query_lower + 1 do
        local substring = path_trim:sub(i, i + #query_lower - 1)
        if levenshtein(query_lower, substring) <= max_dist then
            -- map back to original path
            local orig_start = index_map[i]
            local orig_end = index_map[i + #query_lower - 1]
            table.insert(matches, {orig_start, orig_end})
            break
        end
    end

    ::skip::

    return matches
end

function M.scout()
    menu.open_menu({

    -- Result
    function(buf, bufs)
        vim.bo[buf].modifiable = true

        -- Get the files
        local entries = vim.fn.globpath('.', '**/*', false, true)
        local files = {}
        for _, path in ipairs(entries) do
            if vim.fn.isdirectory(path) == 0 then
                -- Exclude files with a filetype in the exclude_filetypes list
                local ext = path:match('%.([^.]+)$')
                local exclude = false
                if ext then
                    ext = ext:lower()
                    for _, bad in ipairs(excluded_filetypes) do
                        if ext == bad then
                            exclude = true
                            break
                        end
                    end
                end
                if not exclude then
                    local trim = path:gsub('^%./', '')
                    table.insert(files, '  ' .. trim)
                end
            end
        end

        local fuzzy_files = {}
        local highlights = {}
        local search = vim.api.nvim_buf_get_lines(bufs[2], 0, 1, false)[1]:sub(3)

        -- Fuzzy sort
        if search ~= '' then
            for _, file in ipairs(files) do
                local finds = M.fuzzy_string_match(search, file)
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
                local start_col = match[1] - 1
                local end_col = math.min(match[2], #buf_line)
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
        if not line then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
            return
        end

        local path = line:sub(3)
        if path == '' then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
            return
        end
        local relative_path = './' .. path

        local lines = vim.fn.readfile(relative_path)

        -- Remove newlines from each line
        for i = 1, #lines do
            lines[i] = lines[i]:gsub('[\r\n]', '')
        end

        -- Syntax
        local ft = vim.filetype.match({ filename = path })
        if ft then
            vim.bo[buf].filetype = ft
        end

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
        vim.cmd('edit ' .. vim.fn.fnameescape(path))
    end,

    })
end

return M

