local menu = require('scout.menu')
local scout_files = require('scout.files')

local M = {}

local ns_id = vim.api.nvim_create_namespace('ScoutFilesHL')

local function file_exists(path)
    local stat = vim.loop.fs_stat(path)
    return stat ~= nil and stat.type == "file"
end

function M.scout()
    menu.open_menu({

    -- Result
    function(buf, bufs)
        vim.bo[buf].modifiable = true

        local result = vim.api.nvim_exec2('oldfiles', { output = true }).output
        local files = vim.split(result, '\n', { plain = true })

        local fuzzy_files = {}
        local highlights = {}
        local search = vim.api.nvim_buf_get_lines(bufs[2], 0, 1, false)[1]:sub(3)

        -- Remove the numbers from the front
        for i, f in ipairs(files) do
            local file = f:match(' (.*)')
            if file then
                files[i] = '  ' .. file
            end
        end

        -- Fuzzy sort
        if search ~= '' then
            for _, file in ipairs(files) do
                local finds = scout_files.fuzzy_string_match(search, file)
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
        if path == '' or not file_exists(path) then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
            return
        end

        local lines = vim.fn.readfile(path)

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
        if path == '' or not file_exists(path) then return end

        vim.cmd('stopinsert')
        require('scout.menu').close_menu()
        vim.cmd('edit ' .. vim.fn.fnameescape(path))
    end,

    })
end

return M
