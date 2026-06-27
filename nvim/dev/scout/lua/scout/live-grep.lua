local menu = require('scout.menu')

local M = {}

local result_ns_id = vim.api.nvim_create_namespace('ScoutLiveGrepHLResult')
local preview_ns_id = vim.api.nvim_create_namespace('ScoutLiveGrepHLPreview')

local current_job = nil
local current_query = nil
local parsed = {}

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
        callback( {} )
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

function M.scout()
    menu.open_menu({

    -- Result
    function(buf, bufs)
        local lines = {}

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
    function(buf, _, cursor_pos)
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
        vim.api.nvim_buf_set_extmark(buf, preview_ns_id, line_num - 1, 0, {
            end_line = line_num,
            hl_group = 'Visual',
        })

        vim.bo[buf].modifiable = false
    end,

    -- Run
    function(_, cursor_pos)
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
end


return M
