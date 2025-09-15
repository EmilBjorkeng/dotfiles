local core = require('greeter.core')

local M = {}

-- Rute calls made to this module to the functions
-- in the other modules
function M.setup()
    vim.api.nvim_set_hl(0, "AsciiColor", { fg = "#7498A9" })

    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            if vim.fn.argc() == 0 then
                require("greeter").show()
            end
        end
    })
end
M.show = core.show

return M
