local commands = require('hidden-tabs.commands')
local autocmds = require('hidden-tabs.autocmds')

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
function M.setup()
    vim.api.nvim_set_hl(0, "HiddenTabs", { bg = "#1a55eb" })

    autocmds.setup()
    commands.setup()
end

return M
