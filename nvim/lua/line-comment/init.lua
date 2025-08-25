local keymaps = require('line-comment.keymaps')
local commands = require('line-comment.commands')

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
function M.setup()
    keymaps.setup()
    commands.setup()
end

return M
