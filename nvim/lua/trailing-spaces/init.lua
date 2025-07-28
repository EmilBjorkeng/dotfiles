local utils = require("trailing-spaces.utils")

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
M.setup = utils.setup
M.refresh = utils.refresh
M.highlight_trailing_spaces = utils.highlight_trailing_spaces
M.remove_trailing_spaces = utils.remove_trailing_spaces

return M
