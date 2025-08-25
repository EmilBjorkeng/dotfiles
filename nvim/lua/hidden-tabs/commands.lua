local core = require('hidden-tabs.core')

local M = {}

function M.setup()
    vim.api.nvim_create_user_command("TabsToSpaces", function()
        core.tabs_to_spaces()
    end, { desc = "Changes all tabs into spaces", })
end

return M
