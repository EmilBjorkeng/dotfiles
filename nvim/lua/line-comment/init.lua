local utils = require("line-comment.utils")

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
M.setup = utils.setup
M.toggle_comment = utils.toggle_comment

return M
