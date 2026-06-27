local core = require('end-hl-lua.core')

local M = {}
    
local group = vim.api.nvim_create_augroup('EndHighLightLua', { clear = true })

function M.setup()
    vim.api.nvim_create_autocmd({
        'BufEnter', 'CursorMoved', 'CursorMovedI'
    }, {
        group = group,
        callback = function()
            core.refresh()
        end,
    })
end

return M
