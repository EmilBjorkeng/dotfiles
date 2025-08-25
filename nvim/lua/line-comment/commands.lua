local core = require('line-comment.core')

local M = {}

function M.setup()
    vim.api.nvim_create_user_command('LC', function(opts)
        local cmd_args = opts.fargs
        local cmd_arg = cmd_args[1]
        local cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        local args = {}

        -- Args StartLine:EndLine
        if opts.range == 0 then
            if cmd_arg == nil then
                core.toggle_comment()
                return
            end

            for arg in cmd_arg:gmatch("([^:]+)") do
                table.insert(args, arg)
            end

            if #args ~= 2 then
                vim.notify('Wrong arg count', vim.log.levels.WARN)
                return
            end

        -- Range (Visual)
        else
            args = { tostring(opts.line1), tostring(opts.line2) }
        end

        local function is_number(var, num)
            local name = { 'StartLine', 'EndLine' }
            if type(var) ~= 'number' then
                vim.notify(name[num] .. ' is not a number', vim.log.levels.WARN)
                return false
            end
            return true
        end

        -- If the arg starts with a + or - add that to the cursors possition
        for i = 1, 2 do
            if args[i]:sub(1,1) == '+' then
                local num = tonumber(args[i]:sub(2))
                if not is_number(num, i) then return end
                args[i] = tostring(cursor_row + num)
            elseif args[i]:sub(1,1) == '-' then
                local num = tonumber(args[i]:sub(2))
                if not is_number(num, i) then return end
                args[i] = tostring(cursor_row - num)
            end
        end

        -- Convert to number and round down
        local lines = {}
        for i = 1, 2 do
            lines[i] = tonumber(args[i])
            if not is_number(lines[i], i) then return end
            lines[i] = math.floor(lines[i])
        end

        -- Sort so the smalles is always first
        table.sort(lines, function(a, b)
            return a < b
        end)

        -- Clamp the lines to inside the buffer
        local maxline = vim.api.nvim_buf_line_count(0)
        lines[1] = math.max(1, math.min(lines[1], maxline))
        lines[2] = math.max(1, math.min(lines[2], maxline))

        core.toggle_section(lines[1], lines[2])
    end , {
        range = true,
        nargs = '?',
        complete = function(ArgLead, CmdLine, CursorPos)
            local parts = vim.split(CmdLine, " ")
            if #parts == 2 then
                return { 'StartLine:EndLine' }
            end
        end,
        desc = 'Toggles comment state of multiple lines'
    })
end

return M
