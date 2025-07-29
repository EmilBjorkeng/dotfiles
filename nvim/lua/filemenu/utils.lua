local M = {}

function M.setup()
    vim.api.nvim_create_user_command("File",
        ':lua require("filemenu").open_menu()<CR>',
        { desc = "Open Filesystem menu", })

    -- Set up colors
    vim.api.nvim_set_hl(0, "FilemenuBlue", { fg = "#7498A9" })
    vim.api.nvim_set_hl(0, "FilemenuGrey", { fg = "#858585" })
    vim.api.nvim_set_hl(0, "FilemenuPurple", { fg = "#7960a4" })
    vim.api.nvim_set_hl(0, "FilemenuOrange", { fg = "#a7371b" })
    vim.api.nvim_set_hl(0, "FilemenuGreen", { fg = "#8A9F37" })
end

return M
