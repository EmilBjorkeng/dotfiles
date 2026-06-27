local core = require('end-hl-lua.core')
local autocmds = require('end-hl-lua.autocmds')

local M = {}

function M.setup()
    autocmds.setup()
end

return M
