local commands = require('hidden-tabs.commands')
local autocmds = require('hidden-tabs.autocmds')
local core = require('hidden-tabs.core')

local M = {}

local config = {
    autoshow = true
}

function M.setup(opts)
    opts = vim.tbl_deep_extend("force", config, opts or {})

    vim.api.nvim_set_hl(0, "HiddenTabs", { bg = "#0022fe" })

    autocmds.setup()
    commands.setup()

    core.enabled = opts.autoshow
    core.refresh()
end

return M
