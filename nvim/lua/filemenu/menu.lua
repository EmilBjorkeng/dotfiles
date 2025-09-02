local core = require("filemenu.core")

local ns_id = vim.api.nvim_create_namespace("filemenu")
local cursor_ns_id = vim.api.nvim_create_namespace("menu_cursor")

local buf, win

local M = {}

local mappings = {
    q = 'close_menu()',
    ['.'] = 'reset_path()',
    ['<CR>'] = 'menu_select("CR")',
    s = 'menu_select("s")',
    v = 'menu_select("v")',
    t = 'menu_select("t")'
}

local menu_width = 60
local menu_height = 20

local scroll, overflow, info_length

function M.get_current_buf()
    return buf
end

function M.reload_menu()
    scroll = 0
    M.redraw()
end

function M.set_mappings()
    for k,v in pairs(mappings) do
        vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("filemenu").'..v..'<CR>', {
            nowait = true, noremap = true, silent = true
        })
    end
end

function M.redraw()
    -- Get line data
    local entries = core.build_menu_lines()
    local content_lines = {}
    for _, entry in ipairs(entries) do
        table.insert(content_lines, entry.display)
    end
    local info_lines = core.info_lines()
    info_lines[#info_lines+1] = '---' -- Add seperator
    info_length = #info_lines

    -- Combine info and content into lines
    local lines = {}
    for _, v in ipairs(info_lines) do
        table.insert(lines, v)
    end
    for i = scroll, menu_height - #info_lines + scroll do
        table.insert(lines, content_lines[i + scroll])
    end

    overflow = #content_lines - scroll + #info_lines - menu_height
    local scrollable = overflow > 0
    if (scrollable) then
        table.insert(lines, ' ') -- Add a line to the end to be able to scroll
    end

    -- Modify buffer
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local width = core.display_name_width + 3
    local start_index = #info_lines + 1
    local end_index = #lines - ((scrollable and 1) or 0)

    for i = start_index, end_index do
        local entry = entries[i - #info_lines + scroll]
        if entry.is_dir then
            -- Highlight directories
            vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, 0, {
                end_col = width,
                hl_group = "FilemenuBlue"
            })
        end

        -- Don't include the date in the mode coloring
        local date_length = (i == #info_lines+1 and 0) or (i > #info_lines+1 and 16) or 0

        -- Mode highlight
        local line = lines[i]
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

function M.create_win()
    buf = vim.api.nvim_create_buf(false, true)

    -- Get size of the parent window
    local parent_width = vim.api.nvim_win_get_width(0)
    local parent_height = vim.api.nvim_win_get_height(0)

    -- Create floating window
    vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = menu_width,
        height = menu_height,
        col = (parent_width / 2) - (menu_width /  2),
        row = (parent_height / 2) - (menu_height /  2),
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

    M.set_mappings()
end

function M.open_menu()
    local path = vim.api.nvim_buf_get_name(0)
    local dir = path:match("(.*/)")
    vim.fn.chdir(dir)
    scroll = 0

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

function M.update_virt_cursor()
    if not buf then return end
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local current_buf = vim.api.nvim_get_current_buf()

    -- Check if the buffer is currently focused
    if current_buf == buf then
        -- Buffer is focused, show custom cursor
        local line = vim.api.nvim_win_get_cursor(0)[1] - 1
        vim.api.nvim_buf_clear_namespace(buf, cursor_ns_id, 0, -1)
        vim.api.nvim_buf_set_extmark(buf, cursor_ns_id, line, 0, {
            virt_text = { { ">", "Normal" } },
            virt_text_pos = "overlay",
        })
    else
        -- Buffer is not focused, hide custom cursor
        vim.api.nvim_buf_clear_namespace(buf, cursor_ns_id, 0, -1)
    end
end

function M.cursor_position_logic()
    local cl, cc = unpack(vim.api.nvim_win_get_cursor(0))
    if cl <= info_length then
        -- Scroll up
        scroll = scroll - 1
        if scroll < 0 then scroll = 0 end

        -- Don't let the cursor enter the info panel
        vim.api.nvim_win_set_cursor(0, {info_length+1, cc})
        cl = info_length + 1

    elseif cl >= menu_height + 1 then
        scroll = scroll + 1
        if scroll > overflow then scroll = overflow + 1 end
        vim.api.nvim_win_set_cursor(0, {menu_height, cc})

        -- Scroll up again to get everything into view
        local view = vim.fn.winsaveview()
        view.topline = 1
        vim.fn.winrestview(view)
    end
end

return M
