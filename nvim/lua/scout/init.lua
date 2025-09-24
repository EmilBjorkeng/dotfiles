local commands = require('scout.commands')
local core = require('scout.core')

local M = {}

local config = {
    start_in_search = false
}

function M.setup(opts)
    opts = vim.tbl_deep_extend("force", config, opts or {})

    vim.cmd [[ hi ScoutCursor guibg=#ffffff blend=100 ]]
    vim.api.nvim_set_hl(0, "ScoutHL", { fg = "#7497A9" })

    core.start_in_search = opts.start_in_search
    commands.setup()
end

return M
