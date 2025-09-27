local menu = require('scout.menu')

local M = {}

local result_ns_id = vim.api.nvim_create_namespace('ScoutResultHL')
local preview_ns_id = vim.api.nvim_create_namespace('ScoutPreviewHL')
M.start_in_search = false

local current_job = nil
local current_query = nil
local parsed = {}

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

local function fuzzy_string_match(query, path)
    local query_lower = query:lower()
    local max_dist = 1      -- Tolerance for the fuzzy check
    local min_query_len = 3 -- Minimum length the query has to be to be fuzzy checked

    local path_lower = path:lower()
    local path_trim = path_lower:gsub('/', '')
    -- local parts = vim.split(path_trim, '/')

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
                local start_col = match[1] - 1
                local end_col = math.min(match[2], #buf_line)
                vim.api.nvim_buf_set_extmark(buf, result_ns_id, line - 1, start_col, {
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

    if M.start_in_search then
        -- Start in the search bar
        require('scout.menu').start_search()
    end
end

local function parse_line(line)
    local parts = vim.split(line, ':', { plain = true })
    return {
        filename = parts[1],
        lnum = tonumber(parts[2]),
        col = tonumber(parts[3]),
        text = table.concat(parts, ':', 4)
    }
end

local function run_rg(query, callback)
    if vim.fn.executable('rg') == 0 then
        vim.notify('ripgrep (rg) is required but not installed', vim.log.levels.ERROR)
        return
    end

    -- Ignore for short queries
    if #query < 1 then
        callback( { } )
        return
    end

    local cmd = {
        'rg', '--vimgrep', '--hidden', '--glob', '!.git/*', query, '.'
    }

    local results = {}

    -- Stro re-querying
    if current_query == query then
        return
    end

    -- Close any background jobs if present
    if current_job then
        vim.fn.jobstop(current_job)
    end

    current_query = query
    current_job = vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            for _, line in ipairs(data) do
                if line ~= '' then
                    table.insert(results, line)
                end
            end
        end,
        on_exit = function()
            current_job = nil
            table.sort(results)
            callback(results)
        end,
    })
end

function M.scout_grep()
    menu.open_menu({

    -- Result
    function(buf, bufs) 
        local lines = {}
        local highlights = {} 

        local search = vim.api.nvim_buf_get_lines(bufs[2], 0, 1, false)[1]:sub(3)
        run_rg(search, function(results)

            -- Get padding and parse
            parsed = {}
            local padding = 0
            for _, v in ipairs(results) do
                local list = parse_line(v)
                 list.filename = list.filename:gsub('^%./', '')
                 list.text = list.text:match('^%s*(.-)%s*$')

                table.insert(parsed, list)
                if #list.filename > padding  then
                    padding = #list.filename
                end
            end
            padding = padding + 3

            -- Generate lines
            for _, v in ipairs(parsed) do 
                local path = v.filename
                local line = '  ' .. path .. string.rep(' ', padding - #path) .. v.text                
                table.insert(lines, line)
            end

            -- Fallback
            if #lines == 0 then
                lines = { ' ' }
            end
            
            vim.bo[buf].modifiable = true
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.bo[buf].modifiable = false

            -- Highlight
            for line, v in ipairs(parsed) do
                local start = 1
                while true do
                    local start_index, end_index = string.find(v.text, search, start, true)
                    if not start_index then break end
                    
                    vim.api.nvim_buf_set_extmark(buf, result_ns_id, line - 1, start_index + padding + 1, {
                        end_col = end_index + padding + 2,
                        hl_group = 'ScoutHL'
                    })

                    start = end_index + 1
                end
            end
        end)
    end,

    -- Preview
    function(buf, bufs, cursor_pos)
        vim.bo[buf].modifiable = true

        -- Get content
        local pars = parsed[cursor_pos + 1]
        if not pars then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
            return
        end

        local path = pars.filename
        local relative_path = './' .. path
        local line_num = pars.lnum

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

        -- Scroll down to the line the grep found
        local winid = vim.fn.bufwinid(buf)
        vim.api.nvim_win_set_cursor(winid, { line_num, 0 })
        vim.api.nvim_win_call(winid, function()
            vim.cmd('normal! zz')
        end)

        -- Highlight the line
        vim.api.nvim_buf_clear_namespace(buf, preview_ns_id, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, preview_ns_id, 'Visual', line_num - 1, 0, -1)

        vim.bo[buf].modifiable = false
    end,

    -- Run
    function(bufs, cursor_pos)
        -- Get content
        local pars = parsed[cursor_pos + 1]
        if not pars then return end

        local path = pars.filename
        local line_num = pars.lnum

        vim.cmd('stopinsert')
        require('scout.menu').close_menu()
        vim.cmd('edit ' .. vim.fn.fnameescape(path))

        vim.api.nvim_win_set_cursor(0, { line_num, 0 })
    end,

    })

    if M.start_in_search then
        -- Start in the search bar
        require('scout.menu').start_search()
    end
end

return M
