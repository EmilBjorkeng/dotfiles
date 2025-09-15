local core = require('hexcolor.core')

local M = {}

function M.setup()
    vim.api.nvim_create_user_command('Hexcolor', function(opts)
        local subcmd = opts.args:lower()
        if subcmd == 'refresh' then
            core.refresh()
        elseif subcmd == 'toggle' then
            core.toggle()
        else
            vim.notify('Unknown subcommand: ' .. subcmd .. '. Use "Refresh" or "Toggle".', vim.log.levels.WARN)
        end
    end, {
        nargs = 1,
        complete = function(ArgLead, CmdLine, CursorPos)
            local subcmds = { 'Refresh', 'Toggle' }
            local matches = {}
            local lead = ArgLead:lower()
            for _, cmd in ipairs(subcmds) do
                if cmd:lower():find('^' .. lead) then
                    table.insert(matches, cmd)
                end
            end
            return matches
        end,
        desc = 'Hexcolor commands: Refresh or Toggle',
    })
end

return M
