local utils = require('greeter.utils')
local autocmds = require('greeter.autocmds')

local ns_id = vim.api.nvim_create_namespace("greeter")

local M = {}

local mappings = {
    e = ':ene<CR>',
    f = ':File<CR>',
    q = ':qa<CR>>',
}

local menu = {
    { "New File",   "e", "" },
    { "Find File",  "f", "" },
    { "Quit",       "q", " " },
}
local menu_spacing = 42

function M.set_mappings(buf)
    for k,v in pairs(mappings) do
        vim.api.nvim_buf_set_keymap(buf, 'n', k, v, {
            nowait = true, noremap = true, silent = true
        })
    end
end

function M.show()
    -- Open a scratch buffer
    vim.cmd("enew")
    local buf = vim.api.nvim_get_current_buf()

    -- Set buffer options
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].modifiable = true

    local top = {}
    local bottom = {}

    -- Ascii
    local ascii, ascii_pad = utils.center_block(utils.ascii)
    utils.table_append(top, ascii)
    utils.table_append(top, utils.spacing(5))

    -- Menu
    local menu_lines = {}
    for _,v in ipairs(menu) do
        local name = v[1]
        local key = v[2]
        local icon = v[3].."  "

        table.insert(menu_lines,
            icon .. string.format("%-" .. menu_spacing .. "s", name) .. key
        )
        table.insert(menu_lines,"")
    end
    table.remove(menu_lines)
    menu_lines = utils.center_block(menu_lines)
    utils.table_append(top, menu_lines)

    -- Bottom

    -- Combine top and bottom with spacing between
    local height = vim.api.nvim_win_get_height(0)
    local tb_space = height - #top - #bottom - 1

    local tb_space_lines = {}
    for _ = 0, tb_space do
        table.insert(tb_space_lines, "")
    end

    local lines = utils.combine_lines(top, tb_space_lines)
    lines = utils.combine_lines(lines, bottom)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Color
    for row = 0, #ascii - 1 do
        local line_len = #vim.api.nvim_buf_get_lines(buf, row, row+1, false)[1]
        vim.api.nvim_buf_set_extmark(buf, ns_id, row, ascii_pad, {
            hl_group = "AsciiColor",
            end_col = line_len,
            hl_eol = true,
        })
    end
    vim.bo[buf].modifiable = false

    M.set_mappings(buf)
    autocmds.setup(buf)
end

return M
