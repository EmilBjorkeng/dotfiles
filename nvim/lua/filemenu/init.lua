local commands = require("filemenu.commands")
local autocmds = require("filemenu.autocmds")
local menu = require("filemenu.menu")
local core = require("filemenu.core")

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
M.setup = function()
    commands.setup()
    autocmds.setup()

    -- Set up colors
    vim.api.nvim_set_hl(0, "FilemenuBlue", { fg = "#7498A9" })
    vim.api.nvim_set_hl(0, "FilemenuGrey", { fg = "#858585" })
    vim.api.nvim_set_hl(0, "FilemenuPurple", { fg = "#7960a4" })
    vim.api.nvim_set_hl(0, "FilemenuOrange", { fg = "#a7371b" })
    vim.api.nvim_set_hl(0, "FilemenuGreen", { fg = "#8A9F37" })
end
M.redraw = menu.redraw
M.close_menu = menu.close_menu
M.reload_menu = menu.reload_menu
M.menu_select = core.menu_select
M.reset_path = core.reset_path

return M
