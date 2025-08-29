local core = require("filemenu.core")

local buf, win, start_win
local cursor_ns_id = vim.api.nvim_create_namespace("menu_cursor")
local ns_id = vim.api.nvim_create_namespace("filemenu")

local M = {}

local mappings = {
    q = 'close_menu()',
    ['.'] = 'reset_path()',
    ['<CR>'] = 'menu_select("CR")',
    s = 'menu_select("s")',
    v = 'menu_select("v")',
    t = 'menu_select("t")'
}

function M.set_mappings()
    for k,v in pairs(mappings) do
        vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("filemenu").'..v..'<CR>', {
            nowait = true, noremap = true, silent = true
        })
    end
end

function M.redraw()
    local entries = core.build_menu_lines()
    local lines = {}
    for _, entry in ipairs(entries) do
        table.insert(lines, entry.display)
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local width = core.display_name_width + 3
    for i, entry in ipairs(entries) do
        if entry.is_dir then
            -- Highlight directories
            vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, 0, {
                end_col = width,
                hl_group = "FilemenuBlue"
            })
        end

        -- Don't include the date in the mode coloring
        local date_length = (i == 1 and 0) or (i > 1 and 16) or 0

        -- Mode highlight
        local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
        for col = width, #line - date_length do
            local ch = line:sub(col, col)
            local hl_group = nil

            -- Highlight all the dashes
            if ch == "-" then
                hl_group = "FilemenuGrey"
            -- Highlight the different parts of the mode
            elseif ch == "d" then
                hl_group = "FilemenuBlue"
            elseif ch == "r" then
                hl_group = "FilemenuPurple"
            elseif ch == "w" then
                hl_group = "FilemenuOrange"
            elseif ch == "x" then
                hl_group = "FilemenuGreen"
            end

            if hl_group then
                vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, col - 1, {
                    end_col = col,
                    hl_group = hl_group
                })
            end
        end
        -- Highlight date
        vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, width + 11, {
            end_line = i - 1,
            end_col = #line,
            hl_group = "FilemenuBlue"
        })
    end
    vim.bo[buf].modifiable = false
end

local function cursor_autocmd(bufnr)
    local original_guicursor = vim.o.guicursor
    vim.cmd [[ hi FileMenuCursor guibg=#ffffff blend=100 ]]

    vim.api.nvim_create_autocmd("BufEnter", {
        buffer = bufnr,
        callback = function()
            vim.o.guicursor =
                "n-v:block-FileMenuCursor,i-ve:ver25-FileMenuCursor,r:hor20-FileMenuCursor"
        end,
    })

    -- Show cursor on buffer leave
    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = bufnr,
        callback = function()
            vim.o.guicursor = original_guicursor
        end,
    })
end

function M.create_win()
    start_win = vim.api.nvim_get_current_win()
    buf = vim.api.nvim_create_buf(false, true)

    cursor_autocmd(buf)

    -- Get size of the parent window
    local parent_width = vim.api.nvim_win_get_width(0)
    local parent_height = vim.api.nvim_win_get_height(0)

    -- Size of the window
    local width = 60
    local height = 20

    -- Create floating window
    vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = (parent_width / 2) - (width /  2),
        row = (parent_height / 2) - (height /  2),
        style = 'minimal',
        anchor = 'NW',
        border = 'rounded',
        title = 'File Browser',
        title_pos = 'center'
    })

    -- Save window handle
    win = vim.api.nvim_get_current_win()

    -- Prevents no save errors
    vim.bo[0].buftype = "nofile"
    -- Disables swap files for the menu
    vim.bo[0].swapfile = false
    -- Destroy buffer if hidden
    vim.bo[0].bufhidden = "wipe"

    -- Local settings for the menu
    vim.api.nvim_command('setlocal wrap')
    vim.wo[win].winhl = "Normal:Normal,FloatBorder:Normal,FloatTitle:Normal"

    -- Set custom cursor in the menu and movement restriction
    vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = buf,
        callback = function()
            -- Custom cursor
            local line = vim.api.nvim_win_get_cursor(0)[1] - 1

            -- Clear all extmarks in this namespace for the buffer
            vim.api.nvim_buf_clear_namespace(buf, cursor_ns_id, 0, -1)

            -- Set virt text ">" with a highlight group, at col 0
            vim.api.nvim_buf_set_extmark(buf, cursor_ns_id, line, 0, {
                virt_text = { { ">", "Normal" } },
                virt_text_pos = "overlay",
            })
        end,
    })

    M.set_mappings()
end

function M.open_menu()
    local path = vim.api.nvim_buf_get_name(0)
    local dir = path:match("(.*/)")
    vim.fn.chdir(dir)

    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_current_win(win)
    else
        M.create_win()
    end
    M.redraw()
end

function M.close_menu()
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
end

return M
