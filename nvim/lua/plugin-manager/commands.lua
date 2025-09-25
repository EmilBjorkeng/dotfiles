local menu = require('plugin-manager.menu')

local M = {}

function M.setup()
    vim.api.nvim_create_user_command("PM", function()
        menu.open_menu()
    end, { desc = "Open Plugin Manager menu", })
end

return M
