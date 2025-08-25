local M = {}

function M.setup()
    vim.keymap.set({'n', 'i'}, "<C-7>", function()
        require('line-comment.core').toggle_comment()
    end, { silent = true })
end

return M
