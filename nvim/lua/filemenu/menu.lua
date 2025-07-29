local filemenu = require("filemenu.filemenu")

local buf, win, start_win
local ns = vim.api.nvim_create_namespace("menu_cursor")

local M = {}

local mappings = {
    q = 'close_menu()',
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
    local entries = filemenu.build_menu_lines()
    local lines = {}
    for _, entry in ipairs(entries) do
        table.insert(lines, entry.display)
    end

	vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local width = filemenu.display_name_width + 3
    for i, entry in ipairs(entries) do
        if entry.is_dir then
            -- Highlight directories
            vim.api.nvim_buf_add_highlight(buf, -1, "FilemenuBlue", i - 1, 0, width)
        end

        -- Don't include the date in the mode coloring
        local date_length = (i == 1 and 0) or (i > 1 and 16) or 0

        -- Mode highlight
        local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
        for col = width, #line - date_length do
            if line:sub(col, col) == "-" then
                -- Highlight all the dashes
                vim.api.nvim_buf_add_highlight(buf, -1, "FilemenuGrey", i - 1, col - 1, col)

            -- Highlight the different parts of the mode
            elseif line:sub(col, col) == "d" then
                vim.api.nvim_buf_add_highlight(buf, -1, "FilemenuBlue", i - 1, col - 1, col)
            elseif line:sub(col, col) == "r" then
                vim.api.nvim_buf_add_highlight(buf, -1, "FilemenuPurple", i - 1, col - 1, col)
            elseif line:sub(col, col) == "w" then
                vim.api.nvim_buf_add_highlight(buf, -1, "FilemenuOrange", i - 1, col - 1, col)
            elseif line:sub(col, col) == "x" then
                vim.api.nvim_buf_add_highlight(buf, -1, "FilemenuGreen", i - 1, col - 1, col)
            end
        end
        -- Highlight date
        vim.api.nvim_buf_add_highlight(buf, -1, "FilemenuBlue", i - 1, width + 11, -1)
    end
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

function M.create_win()
    start_win = vim.api.nvim_get_current_win()
    buf = vim.api.nvim_create_buf(false, true)

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
	vim.api.nvim_buf_set_option(0, 'buftype', 'nofile')
    -- Disables swap files for the menu
	vim.api.nvim_buf_set_option(0, 'swapfile', false)
    -- Destroy buffer if hidden
	vim.api.nvim_buf_set_option(0, 'bufhidden', 'wipe')

    -- Local settings for the menu
	vim.api.nvim_command('setlocal wrap')
    vim.api.nvim_win_set_option(win, 'winhighlight', 'Normal:Normal,FloatBorder:Normal,FloatTitle:Normal')

    -- Set custom cursor in the menu and movement restriction
    vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = buf,
        callback = function()
            -- Custom cursor
            local line = vim.api.nvim_win_get_cursor(0)[1] - 1

            -- Clear all extmarks in this namespace for the buffer
            vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

            -- Set virt text ">" with a highlight group, at col 0
            vim.api.nvim_buf_set_extmark(buf, ns, line, 0, {
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
