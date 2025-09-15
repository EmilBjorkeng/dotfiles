local core = require('hidden-tabs.core')

local M = {}

function M.setup()
        vim.api.nvim_create_user_command('Tabs', function(opts)
        local subcmd = opts.args:lower()
        if subcmd == 'remove' then
            core.tabs_to_spaces()
        elseif subcmd == 'toggle' then
            core.toggle()
        else
            vim.notify('Unknown subcommand: ' .. subcmd .. '. Use "Remove" or "Toggle".', vim.log.levels.WARN)
        end
    end, {
        nargs = 1,
        complete = function(ArgLead, CmdLine, CursorPos)
            local subcmds = { 'Remove', 'Toggle' }
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
