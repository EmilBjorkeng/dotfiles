local commands = require('trailing-spaces.commands')
local autocmds = require('trailing-spaces.autocmds')

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
M.setup = function()
    autocmds.setup()
    commands.setup()
end

return M
