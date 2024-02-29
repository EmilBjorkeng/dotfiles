local utils = require("plugin-manager.utils")

local buf, win, start_win

local M = {}

local mappings = {
    q = 'close_menu()',
}

function M.set_mappings()
    for k,v in pairs(mappings) do
        vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("plugin-manager").'..v..'<CR>', {
            nowait = true, noremap = true, silent = true
        })
    end
end

function M.redraw()
    local errors = utils.errors
    local error_messages = utils.error_messages

    local lines = {}
    if (#errors < 1) then 
        lines = {"No Errors"}
    else
        for i=1,#errors,1 do
            table.insert(lines, "> "..utils.errors[1])
            table.insert(lines, utils.error_messages[1])
            table.insert(lines, "") -- Space
        end
        table.remove(lines, #lines)
    end

	vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

function M.create_win()
    start_win = vim.api.nvim_get_current_win()
    buf = vim.api.nvim_create_buf(false, true)

    -- Get size of the parent window
    local parent_width = vim.api.nvim_win_get_width(0)
    local parent_height = vim.api.nvim_win_get_height(0)

    -- Size of the window
    local width = 45
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
        title = 'Plugin-manager Errors',
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
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:Normal,FloatBorder:Normal,FloatTitle:Normal')

    M.set_mappings()
end

function M.open_menu()
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
