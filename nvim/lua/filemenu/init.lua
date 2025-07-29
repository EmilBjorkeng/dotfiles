local utils = require("filemenu.utils")
local menu = require("filemenu.menu")
local filemenu = require("filemenu.filemenu")

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
M.setup = utils.setup
M.redraw = menu.redraw
M.create_win = menu.create_win
M.open_menu = menu.open_menu
M.close_menu = menu.close_menu
M.menu_select = filemenu.menu_select

return M
