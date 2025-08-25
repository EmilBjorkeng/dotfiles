local menu = require('plugin-manager.menu')

local M = {}

function M.setup()
    vim.keymap.set('n', 'm', function()
        menu.open_menu()
    end, { silent = true })
end

return M
