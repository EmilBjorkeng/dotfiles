local commands = require('git-status.commands')
local core = require('git-status.core')

local M = {}

local config = {
    autoshow = true
}

M.setup = function(opts)
    opts = vim.tbl_deep_extend('force', config, opts or {})

    core.define_combined_signs()
    commands.setup()

    if opts.autoshow then
        core.enable_git_status()
    end
end

return M
