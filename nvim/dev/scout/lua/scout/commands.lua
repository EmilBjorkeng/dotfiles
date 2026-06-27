local core = require('scout.core')

local M = {}

local subcmds = {
    {'Files', 'files'},
    {'Live_Grep', 'live-grep'},
    {'Oldfiles', 'oldfiles'}
}

function M.setup()
    vim.api.nvim_create_user_command('Scout', function(opts)
        local subcmd = opts.args:lower()

        local match = false
        for _, v in ipairs(subcmds) do
            local name = v[1]
            local cmd = v[2]
            if(name:lower() == subcmd) then
                core.scout(cmd)
                match = true
                break
            end
        end

        if not match then
            vim.notify('Unknown subcommand: ' .. subcmd .. '.', vim.log.levels.WARN)
        end
    end, {
        nargs = 1,
        complete = function(ArgLead, CmdLine, CursorPos)
            local matches = {}
            local lead = ArgLead:lower()
            for _, v in ipairs(subcmds) do
                local name = v[1]
                if name:lower():find('^' .. lead) then
                    table.insert(matches, name)
                end
            end
            return matches
        end,
        desc = 'Scout Command',
    })
end

return M
