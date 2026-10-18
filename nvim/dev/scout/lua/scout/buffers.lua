local menu = require('scout.menu')
local scout_files = require('scout.files')
local utils = require('scout.utils')

local M = {}

local ns_id = vim.api.nvim_create_namespace('ScoutBuffersHL')
local buffers = {}
local shown = {}

-- Snapshot the buffer list before the menu takes focus
local function collect_buffers()
    local origin = vim.api.nvim_get_current_buf()
    local infos = vim.fn.getbufinfo({ buflisted = 1 })
    table.sort(infos, function(a, b) return a.lastused > b.lastused end)

    local list = {}
    for _, info in ipairs(infos) do
        if info.bufnr ~= origin
            and info.name ~= ''
            and vim.bo[info.bufnr].buftype == '' then
            table.insert(list, {
                bufnr = info.bufnr,
                path = info.name,
                name = vim.fn.fnamemodify(info.name, ':~:.'),
                modified = info.changed == 1,
                visible = #vim.fn.win_findbuf(info.bufnr) > 0,
            })
        end
    end
    return list
end

function M.scout()
    buffers = collect_buffers()

    menu.open_menu({

    -- Result
    function(buf, bufs)
        vim.bo[buf].modifiable = true

        local search = vim.api.nvim_buf_get_lines(bufs[2], 0, 1, false)[1]:sub(3)
        local lines = {}
        local highlights = {}
        shown = {}

        for _, b in ipairs(buffers) do
            local line = '  ' .. b.name
            local finds = {}
            if search ~= '' then
                finds = scout_files.fuzzy_string_match(search, line)
            end
            if search == '' or #finds > 0 then
                table.insert(shown, b)
                table.insert(lines, line
                    .. (b.modified and ' [+]' or '')
                    .. (b.visible and ' [w]' or ''))
                table.insert(highlights, finds)
            end
        end

        vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

        for i, matches in ipairs(highlights) do
            for _, match in ipairs(matches) do
                vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, match[1] - 1, {
                    end_col = math.min(match[2], #lines[i]),
                    hl_group = 'ScoutHL',
                })
            end
        end

        vim.bo[buf].modifiable = false
    end,

    -- Preview
    function(buf, _, cursor_pos)
        vim.bo[buf].modifiable = true

        local b = shown[cursor_pos + 1]
        if not b or not vim.api.nvim_buf_is_valid(b.bufnr) then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
            vim.bo[buf].modifiable = false
            return
        end

        -- Loaded buffers show their in-memory state (including unsaved edits)
        local lines
        if vim.api.nvim_buf_is_loaded(b.bufnr) then
            lines = vim.api.nvim_buf_get_lines(b.bufnr, 0, -1, false)
        elseif vim.fn.filereadable(b.path) == 1 then
            lines = vim.fn.readfile(b.path)
        else
            lines = {}
        end

        local ft = vim.bo[b.bufnr].filetype
        if ft == '' then
            ft = vim.filetype.match({ filename = b.path }) or ''
        end
        if ft ~= '' then
            vim.bo[buf].filetype = ft
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
    end,

    -- Run
    function(_, cursor_pos, how)
        local b = shown[cursor_pos + 1]
        if not b then return end

        if how == 'delete' then
            if not utils.delete_buffer(b.bufnr) then return end
            for i, entry in ipairs(buffers) do
                if entry.bufnr == b.bufnr then
                    table.remove(buffers, i)
                    break
                end
            end
            menu.redraw()
            return
        end

        require('scout.open').open(b.path, { how = how })
    end,

    })
end

return M
