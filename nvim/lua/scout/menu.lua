local utils = require('scout.utils')

local M = {}

local ns_id = vim.api.nvim_create_namespace("scout")
local cursor_ns_id = vim.api.nvim_create_namespace("scout_cursor")
local group = vim.api.nvim_create_augroup('LinkedBuffers', { clear = true })
local buf = {}
local win = {}

local original_guicursor
local callbacks, run_func
local result_cursor_pos = 0

local menu_height = 30
local menu_width = 125
local result_width_pct = 40
local preview_width_pct = 60

local mappings = {
    -- Result
    q = {1, function() M.close_menu() end},
    i = {1, function() M.start_search() end},
    ['dd'] = {1, function() M.clear_search() end},

    -- Search
    ['<Esc>'] = {2, function() M.end_search() end},
    ['<Up>'] = {2, function()
        result_cursor_pos = math.max(result_cursor_pos - 1, 0)
        M.virtual_scroll()
        M.redraw()
    end},
    ['<Down>'] = {2, function()
        local line_count = vim.api.nvim_buf_line_count(buf[1])
        result_cursor_pos = math.min(result_cursor_pos + 1, line_count - 1)
        M.virtual_scroll()
        M.redraw()
    end},

    -- Both
    ['<CR>'] = {{1, 2}, function() run_func(buf, result_cursor_pos) end},
}

function M.set_mappings(bufnr)
    for k,v in pairs(mappings) do
        local map_bufs = v[1]
        if type(map_bufs) ~= 'table' then
            map_bufs = { map_bufs }
        end
        local buf_index = utils.index_of(buf, bufnr)

        -- Skip if the buffer doesn't match
        if not utils.index_of(map_bufs, buf_index) then
            goto continue
        end

        local func = v[2]
        local mode = (buf_index == 2) and 'i' or 'n'
        vim.keymap.set(mode, k, func, {
            buffer = bufnr,
            nowait = true, noremap = true, silent = true
        })
        ::continue::
    end
end

function M.start_search()
    if not buf[2] then return end

    -- Set search as the focused window
    local wins = vim.fn.win_findbuf(buf[2])
    vim.api.nvim_set_current_win(wins[1])

    vim.api.nvim_win_set_cursor(0, {1, #vim.api.nvim_get_current_line() })
    vim.api.nvim_feedkeys('a', 'n', false)
end

function M.end_search()
    if not buf[1] then return end

    -- Set Result as the focused window
    local wins = vim.fn.win_findbuf(buf[1])
    vim.api.nvim_set_current_win(wins[1])
    vim.cmd('stopinsert')

    local line_count = vim.api.nvim_buf_line_count(buf[1])
    local cursor_pos = math.max(0, math.min(line_count, result_cursor_pos)) + 1
    vim.api.nvim_win_set_cursor(0, {cursor_pos, 0})
end

function M.clear_search()
    if not buf[2] then return end
    vim.api.nvim_buf_set_lines(buf[2], 0, -1, false, { '> ' })
    M.redraw()
end

function M.virtual_scroll()
    local wins = vim.fn.win_findbuf(buf[1])
    local first_visible = vim.fn.line('w0', win_id)
    local last_visible = vim.fn.line('w$', win_id)

    if result_cursor_pos < first_visible then
        -- Scroll up
        vim.api.nvim_win_set_cursor(wins[1], { first_visible - first_visible - result_cursor_pos, 0 })
    elseif result_cursor_pos > last_visible then
        -- Scroll down
        vim.api.nvim_win_set_cursor(wins[1], { first_visible + result_cursor_pos - last_visible, 0 })
    end
end

function M.redraw()
    callbacks[1](buf[1], buf)                    -- Result
    callbacks[2](buf[3], buf, result_cursor_pos) -- Preview
end

function M.create_menu()
    original_guicursor = vim.o.guicursor
    local height = math.min(menu_height, vim.o.lines)
    local width = math.min(menu_width, vim.o.columns)

    -- Get size of the parent window
    local parent_width = vim.api.nvim_win_get_width(0)
    local parent_height = vim.api.nvim_win_get_height(0)

    local result_width = result_width_pct * width / 100
    local preview_width = preview_width_pct * width / 100

    -- Default opts
    local opts = {
        relative = 'editor',
        style = 'minimal',
        anchor = 'NW',
        border = 'single',
        title_pos = 'center',
        col = (parent_width / 2) - (width/2),
        row = (parent_height / 2) - (height / 2),
    }

    -- Create the buffers
    for i = 1, 3 do
        buf[i] = vim.api.nvim_create_buf(false, true)
    end

    -- Result window
    vim.api.nvim_open_win(buf[1], true,
        utils.table_comb(opts, {
            title = 'Results',
            width = result_width - 1,
            height = height - 3,
            col = opts.col,
            row = opts.row,
        })
    )
    win[1] = vim.api.nvim_get_current_win()

    -- Result cursor
    vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
        buffer = buf[1],
        callback = function()
            local buf = buf[1]
            local current_buf = vim.api.nvim_get_current_buf()

            if not buf then return end
            if not vim.api.nvim_buf_is_valid(buf) then return end
            if current_buf ~= buf then return end

            local line = vim.api.nvim_win_get_cursor(0)[1] - 1
            result_cursor_pos = line

            M.redraw()

            vim.api.nvim_buf_clear_namespace(buf, cursor_ns_id, 0, -1)
            vim.api.nvim_buf_set_extmark(buf, cursor_ns_id, line, 0, {
                virt_text = { { ">", "Normal" } },
                virt_text_pos = "overlay",
            })
            vim.api.nvim_buf_add_highlight(buf, cursor_ns_id, 'Visual', line, 2, -1)

        end
    })
    vim.api.nvim_create_autocmd('BufEnter', {
        buffer = buf[1],
        callback = function()
            vim.o.guicursor =
                'n-v:block-ScoutCursor,i-ve:ver25-ScoutCursor,r:hor20-ScoutCursor'
        end,
    })
    vim.api.nvim_create_autocmd('BufLeave', {
        buffer = buf[1],
        callback = function()
            vim.o.guicursor = original_guicursor
        end,
    })

    -- Search window
    vim.api.nvim_open_win(buf[2], true,
        utils.table_comb(opts, {
            title = 'Search',
            width = result_width - 1,
            height = 1,
            col = opts.col,
            row = opts.row + height - 1,
        })
    )
    win[2] = vim.api.nvim_get_current_win()
    vim.bo[buf[2]].modifiable = true

    vim.api.nvim_create_autocmd({
        'TextChanged', 'TextChangedI', 'BufEnter',
        'CursorMoved', 'CursorMovedI', 'ModeChanged'}, {
        buffer = buf[2],
        callback = function()
            -- Ensure two leading spaces
            local line = vim.api.nvim_buf_get_lines(buf[2], 0, -1, false)[1] or ''
            if not line:match('^  ') then
                line = '> ' .. line:sub(3)
            end
            vim.api.nvim_buf_set_lines(buf[2], 0, -1, false, { line })

            -- Keep the cursor away from the start
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            if col < 2 then
                vim.api.nvim_win_set_cursor(0, { row, 2 })
            end

            M.redraw()

            local line_count = vim.api.nvim_buf_line_count(buf[1])
            result_cursor_pos = math.max(0, math.min(line_count - 1, result_cursor_pos))
            vim.api.nvim_buf_add_highlight(buf[1], cursor_ns_id, 'Visual', result_cursor_pos, 2, -1)
        end,
    })
    vim.api.nvim_buf_set_lines(buf[2], 0, -1, false, { '> ' })

    -- Preview window
    vim.api.nvim_open_win(buf[3], true,
        utils.table_comb(opts, {
            title = 'Prewiew',
            width = preview_width - 1,
            height = height,
            col = opts.col + result_width + 1,
            row = opts.row,
        })
    )
    win[3] = vim.api.nvim_get_current_win()

    for _, bufnr in ipairs(buf) do
        -- Close all winsows simultaneously
        vim.api.nvim_create_autocmd('WinClosed', {
            group = group,
            buffer = bufnr,
            callback = function(ev)
                for _, other_buf in ipairs(buf) do
                    if other_buf ~= ev.buf and vim.api.nvim_buf_is_valid(other_buf) then
                        vim.api.nvim_buf_delete(other_buf, { force = true })
                    end
                end
            end,
        })

        -- Buffer settings
        vim.bo[bufnr].buftype = "nofile"
        vim.bo[bufnr].swapfile = false
        vim.bo[bufnr].bufhidden = "wipe"
        vim.api.nvim_buf_set_option(bufnr, 'wrap', false)

        M.set_mappings(bufnr)
    end

    -- Set border color
    for _, w in ipairs(win) do
        if vim.api.nvim_win_is_valid(w) then
            vim.wo[w].winhl = "Normal:Normal,FloatBorder:Normal,FloatTitle:Normal"
        end
    end

    -- Set result as the focused window
    local wins = vim.fn.win_findbuf(buf[1])
    vim.api.nvim_set_current_win(wins[1])
end

function M.open_menu(func)
    callbacks = { func[1], func[2] }
    run_func = func[3]

    local valid = 0
    for _, w in ipairs(win) do
        if vim.api.nvim_win_is_valid(w) then
            valid = valid + 1
        end
    end

    if valid == 0 then
        -- Create the buffers
        M.create_menu()
    elseif valid == 3 then
        -- Set result (buf[1]) as focus
        local wins = vim.fn.win_findbuf(buf[1])
        vim.api.nvim_set_current_win(wins[1])
    else
        -- Edge case, some buffers are missing
        -- Close everything and reopen
        M.close_menu()
        M.create_menu()
    end

    M.redraw()
end

function M.close_menu()
    for _, w in ipairs(win) do
        if vim.api.nvim_win_is_valid(w) then
            vim.api.nvim_win_close(w, true)
        end
    end
end

return M
