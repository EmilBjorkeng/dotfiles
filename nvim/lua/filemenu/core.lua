local M = {}

M.display_name_width = 30
local fmt = "%-" .. M.display_name_width .. "s %s %s"

local function format_mode(mode, is_dir)
    -- Convert numeric mode to symbolic (e.g., drwxr-xr-x)
    local perms = {
        "r", "w", "x", -- owner
        "r", "w", "x", -- group
        "r", "w", "x"  -- other
    }

    local bits = {}
    for i = 8, 0, -1 do
        table.insert(bits, bit.band(mode, bit.lshift(1, i)) ~= 0)
    end

    local str = is_dir and "d" or "-"
    for i = 1, 9 do
        str = str .. (bits[i] and perms[i] or "-")
    end

    return str
end

local function format_date(epoch)
    return os.date("%Y-%m-%d %H:%M", epoch)
end

function M.build_menu_lines()
    local scandir = vim.loop.fs_scandir(".")
    local entries = {}

    -- Add ../ if not in root
    local cwd = vim.loop.cwd()
    if cwd ~= "/" then
        table.insert(entries, {
            display = "  " .. string.format(fmt, "../", "drwxr-xr-x", ""),
            is_dir = true
        })
    end

    if scandir then
        while true do
            local name, typ = vim.loop.fs_scandir_next(scandir)
            if not name then break end

            local stat = vim.loop.fs_stat(name)
            if stat then
                local is_dir = typ == "directory"
                local display_name = name .. (is_dir and "/" or "")

                local perms = format_mode(stat.mode, is_dir)
                local date = format_date(stat.mtime.sec)

                table.insert(entries, {
                    display = "  " .. string.format(fmt, display_name, perms, date),
                    is_dir = is_dir
                })
            end
        end
    end

    -- Sort directories on top
    table.sort(entries, function(a, b)
        if a.is_dir == b.is_dir then
            local name_a = vim.trim(a.display:sub(1, 30))
            local name_b = vim.trim(b.display:sub(1, 30))
            return name_a < name_b
        else
            return a.is_dir
        end
    end)

    return entries
end

function M.menu_select(button)
    local line_num = vim.api.nvim_win_get_cursor(0)[1]
    local line_text = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]

    if not line_text then return end

    local name = vim.trim(line_text:sub(1, 30))

    if name:sub(-1) == "/" then
        -- Folder
        if button ~= "CR" then return end

        local target = name
        target = target:sub(1, -2)  -- remove trailing /

        -- Change directory
        vim.fn.chdir(target)

        vim.api.nvim_win_set_cursor(0, {1, 0})
        require('filemenu').reload_menu()
    else
        -- File
        local cwd = vim.loop.cwd()
        local path = cwd .. '/' .. name

        require('filemenu').close_menu()

        if button == 'CR' then
            vim.cmd("edit " .. vim.fn.fnameescape(path))
        elseif button == 's' then
            vim.cmd("split " .. vim.fn.fnameescape(path))
        elseif button == 'v' then
            vim.cmd("vsplit " .. vim.fn.fnameescape(path))
        elseif button == 't' then
            vim.cmd("tabnew " .. vim.fn.fnameescape(path))
        end
    end
end

local function get_primary_buffer()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative == "" then
            local buf = vim.api.nvim_win_get_buf(win)
            return buf
        end
    end
    return nil
end

function M.reset_path()
    local buf = get_primary_buffer()
    if not buf then return end

    local path = vim.api.nvim_buf_get_name(buf)
    local dir = path:match("(.*/)")
    vim.fn.chdir(dir)

    vim.api.nvim_win_set_cursor(0, {1, 0})
    require('filemenu').reload_menu()
end

function M.info_lines()
    local path = vim.loop.cwd()
    local path_str = path:gsub("^/home/[^/]+", "~")

    if string.sub(path_str, -1) ~= "/" then
        path_str = path_str .. "/"
    end

    return { path_str }
end

return M
