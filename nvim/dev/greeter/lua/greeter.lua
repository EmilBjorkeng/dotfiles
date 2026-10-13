local core = require('greeter.core')

local M = {}

local function is_empty_start()
    if vim.api.nvim_buf_get_name(0) ~= '' then return false end
    if vim.api.nvim_buf_line_count(0) > 1 then return false end
    return vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == ''
end

M.setup = function()
    vim.api.nvim_set_hl(0, 'AsciiColor', { fg = '#7498A9' })

    vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
            local argc = vim.fn.argc()

            if argc == 0 then
                if is_empty_start() then
                    M.show()
                end
                return
            end

            if argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
                local dir_buf = vim.api.nvim_get_current_buf()
                vim.fn.chdir(vim.fn.argv(0))
                vim.cmd('enew')
                vim.cmd('Scout Files')

                if vim.api.nvim_buf_is_valid(dir_buf) then
                    vim.api.nvim_buf_delete(dir_buf, { force = true })
                end
            end
        end,
    })
end

M.show = core.show

return M
