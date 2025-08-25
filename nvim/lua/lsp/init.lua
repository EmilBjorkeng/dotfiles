local core = require("lsp.core")

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
M.setup = core.setup

return M
