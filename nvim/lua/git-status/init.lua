local utils = require("git-status.utils")

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
M.setup = utils.setup

return M
