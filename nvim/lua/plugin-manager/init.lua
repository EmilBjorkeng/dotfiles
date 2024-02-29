local utils = require("plugin-manager.utils")
local menu = require("plugin-manager.menu")

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
M.setup = utils.setup
M.check_for_plugins = utils.check_for_plugins
M.load_plugins = utils.load_plugins
M.errors = utils.errors
M.error_messages = utils.error_messages
M.redraw = menu.redraw
M.create_win = menu.create_win
M.open_menu = menu.open_menu
M.close_menu = menu.close_menu

return M
