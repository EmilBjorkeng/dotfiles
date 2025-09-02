local menu = require('filemenu.menu')

local M = {}

function M.setup()
    vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
        callback = function()
            local current_buf = vim.api.nvim_get_current_buf()
            if current_buf ~= menu.get_current_buf() then return end

            menu.cursor_position_logic()
            menu.redraw()
            menu.update_virt_cursor()
        end
    })

    -- Cursor visuals
    local original_guicursor = vim.o.guicursor
    vim.cmd [[ hi FileMenuCursor guibg=#ffffff blend=100 ]]

    -- Hide cursor on buffer enter
    vim.api.nvim_create_autocmd('BufEnter', {
        callback = function()
            local current_buf = vim.api.nvim_get_current_buf()
            if current_buf ~= menu.get_current_buf() then return end

            vim.o.guicursor =
                'n-v:block-FileMenuCursor,i-ve:ver25-FileMenuCursor,r:hor20-FileMenuCursor'

            menu.update_virt_cursor()
        end,
    })

    -- Show cursor on buffer leave
    vim.api.nvim_create_autocmd('BufLeave', {
        callback = function()
            local current_buf = vim.api.nvim_get_current_buf()
            if current_buf ~= menu.get_current_buf() then return end

            vim.o.guicursor = original_guicursor

            menu.update_virt_cursor()
        end,
    })
end

return M
