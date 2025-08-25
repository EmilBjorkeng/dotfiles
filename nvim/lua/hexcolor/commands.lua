local core = require('hexcolor.core')

local M = {}

function M.setup()
    vim.api.nvim_create_user_command('HexcolorRefresh', function()
        core.refresh()
    end, { desc = 'Refresh hex colour highlighting' })

    vim.api.nvim_create_user_command('HexcolorToggle', function()
        core.toggle()
    end, { desc = 'Toggle hex colour highlighting' })
end

return M
