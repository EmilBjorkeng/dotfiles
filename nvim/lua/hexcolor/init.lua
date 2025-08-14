local utils = require("hexcolor.utils")

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
M.setup = utils.setup
M.refresh = utils.refresh

return M
