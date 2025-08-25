local commands = require('hexcolor.commands')
local autocmds = require('hexcolor.autocmds')

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
function M.setup()
    autocmds.setup()
    commands.setup()
end

return M
