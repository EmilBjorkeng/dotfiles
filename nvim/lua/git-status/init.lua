local commands = require("git-status.commands")
local core = require("git-status.core")

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
M.setup = function()
    core.define_combined_signs()
    core.enable_git_status()

    commands.setup()
end

return M
