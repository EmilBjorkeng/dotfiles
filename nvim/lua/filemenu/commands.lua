local menu = require('filemenu.menu')

local M = {}

function M.setup()
    vim.api.nvim_create_user_command("File", function()
        menu.open_menu()
    end, { desc = "Open Filesystem menu", })
end

return M
