local core = require('git-status.core')

local M = {}

function M.setup()
    -- Manual refresh command
    vim.api.nvim_create_user_command('GitRefresh', function()
        core.update_git_signs()
    end, {})
    vim.api.nvim_create_user_command('GitToggle', function()
        core.toggle_git_signs()
    end, {})
end

return M
