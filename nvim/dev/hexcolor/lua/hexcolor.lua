local commands = require('hexcolor.commands')
local autocmds = require('hexcolor.autocmds')
local core = require('hexcolor.core')

local M = {}

local config = {
    autoshow = true
}

M.setup = function(opts)
    opts = vim.tbl_deep_extend('force', config, opts or {})

    autocmds.setup()
    commands.setup()

    core.enabled = opts.autoshow
    core.refresh()
end

return M
