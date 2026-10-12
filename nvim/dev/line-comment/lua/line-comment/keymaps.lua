local M = {}

function M.setup()
    vim.keymap.set({'n', 'i'}, '<C-7>', function()
        require('line-comment.core').toggle_comment()
    end, { silent = true, desc = 'Toggles the line comment on the current line' })
end

return M
