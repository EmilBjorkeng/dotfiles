local core = require("plugin-manager.core")
local commands = require("plugin-manager.commands")

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
M.setup = function()
    core.check_for_plugins()
    core.load_plugins()

    commands.setup()
end

return M
