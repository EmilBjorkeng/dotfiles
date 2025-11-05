local utils = require('scout.utils')

local M = {}

local ns_id = vim.api.nvim_create_namespace("plugin-manager")
local buf, win

local mappings = {
    q = 'close_menu()',
}

function M.set_mappings()
    for k,v in pairs(mappings) do
        vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("filemenu").'..v..'<CR>', {
            nowait = true, noremap = true, silent = true
        })
    end
end

local menu_width = 80
local menu_height = 35

function M.redraw()
    local pm = require('plugin-manager')
    local plugins = pm.plugins
    local lookup = pm.lookup
    local loaded = pm.loaded
    local errors = pm.errors

    -- Sorted list of the module names
    local modules = {}
    for plugin, _ in pairs(loaded) do
        table.insert(modules, plugin)
    end
    table.sort(modules)

    vim.bo[buf].modifiable = true

    local lines = {}
    if next(errors) == nil then
        table.insert(lines, 'No plugin Errors')
        table.insert(lines, '')
    else
        for module, error in pairs(errors) do
            table.insert(lines, 'Failed to load module: ' .. module)
            for e in error:gmatch("([^\r\n]+)") do
                table.insert(lines, e)
            end
            table.insert(lines, '')
        end
    end

    -- Get padding
    local padding = 0
    for _, plugin in ipairs(modules) do
        if #plugin > padding then
            padding = #plugin
        end
    end
    padding = padding + 3

    for _, plugin in ipairs(modules) do
        local status = loaded[plugin]
        local str = ''

        -- Loaded status
        if status then
            str = str .. ' '
        elseif errors[plugin] ~= nil then
            str = str .. ' ' 
        else
            str = str .. '  '
        end

        -- Plugin name
        str = str .. plugin
        
        -- Lazy info
        local lazy = lookup[plugin].lazy
        if lazy then
            str = str .. string.rep(' ', padding - #plugin)
            -- ft
            if lazy.ft then
                local ft = lazy.ft
                if type(ft) ~= 'table' then ft = { ft } end

                local ft_str = '(ft: '
                for _, value in ipairs(ft) do
                    ft_str = ft_str .. value .. ', '
                end
                ft_str = ft_str:sub(1, -3) .. ')'

                str = str .. ft_str
            end
            -- event
            if lazy.event then
                local event = lazy.event
                if type(event) ~= 'table' then event = { event } end

                local event_str = '(event: '
                for _, value in ipairs(event) do
                    event_str = event_str .. value .. ', '
                end
                event_str = event_str:sub(1, -3) .. ')'

                str = str .. event_str
            end
            -- cmd
            if lazy.cmd then
                local cmd = lazy.cmd
                if type(cmd) ~= 'table' then cmd = { cmd } end

                local cmd_str = '(cmd: '
                for _, value in ipairs(cmd) do
                    cmd_str = cmd_str .. value .. ', '
                end
                cmd_str = cmd_str:sub(1, -3) .. ')'

                str = str .. cmd_str
            end
        end

        table.insert(lines, str)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Color
    local line = #lines - #modules
    for _, plugin in ipairs(modules) do
        local status = loaded[plugin]
        local hl_group = nil
        if status then
            hl_group = 'PluginCheck'
        elseif errors[plugin] ~= nil then
            hl_group = 'PluginError'
        end

        if hl_group then
            vim.api.nvim_buf_set_extmark(buf, ns_id, line, 0, {
                end_col = 3,
                hl_group = hl_group
            })
        end
        line = line + 1
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
        title = 'Plugin Manager',
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
    -- Turn off wrapping
    vim.api.nvim_buf_set_option(0, 'wrap', false)
    -- Border color
    vim.wo[win].winhl = "Normal:Normal,FloatBorder:Normal,FloatTitle:Normal"

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
