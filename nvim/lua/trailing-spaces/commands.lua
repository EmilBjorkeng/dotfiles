local core = require('trailing-spaces.core')

local M = {}

function M.setup()
    -- Remove Trailing Spaces
    vim.api.nvim_create_user_command("RTS", function()
        core.remove_trailing_spaces()
    end, { desc = "Removes all current trailing spaces", })
end

return M
