local commands = require('trailing-spaces.commands')
local autocmds = require('trailing-spaces.autocmds')
local core = require('trailing-spaces.core')

local M = {}

local config = {
    autoshow = true
}

M.setup = function(opts)
    opts = vim.tbl_deep_extend("force", config, opts or {})

    vim.api.nvim_set_hl(0, "TrailingSpaces", { bg = "#dd0000" })

    autocmds.setup()
    commands.setup()

    core.enabled = opts.autoshow
end

return M
