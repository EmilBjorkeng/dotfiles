local menu = require('scout.menu')

local M = {}

local origin_win = nil

function M.remember_origin()
    local win = vim.api.nvim_get_current_win()
    -- Don't overwrite it with one of Scout's own floating windows
    if vim.api.nvim_win_get_config(win).relative == '' then
        origin_win = win
    end
end

-- opts.how:  'edit' (default), 'vsplit' or 'split'
-- opts.lnum: optional line to jump to
-- opts.col:  optional column (1-based) to jump to
function M.open(path, opts)
    opts = opts or {}
    local how = opts.how or 'edit'

    -- Ignore modes that aren't for opening (e.g. 'delete' from <C-d>)
    if how ~= 'edit' and how ~= 'vsplit' and how ~= 'split' then
        return
    end

    vim.cmd('stopinsert')
    menu.close_menu()

    if origin_win and vim.api.nvim_win_is_valid(origin_win) then
        vim.api.nvim_set_current_win(origin_win)
    end

    -- Reuses the existing buffer if the file is already open
    local bufnr = vim.fn.bufadd(vim.fn.fnamemodify(path, ':p:.'))
    vim.bo[bufnr].buflisted = true

    vim.cmd("normal! m'")

    if how == 'vsplit' then
        vim.cmd('vsplit')
    elseif how == 'split' then
        vim.cmd('split')
    end

    vim.api.nvim_set_current_buf(bufnr)

    if opts.lnum then
        local last = vim.api.nvim_buf_line_count(bufnr)
        local lnum = math.max(1, math.min(opts.lnum, last))
        local col = math.max(0, (opts.col or 1) - 1)
        vim.api.nvim_win_set_cursor(0, { lnum, col })
        vim.cmd('normal! zz')
    end
end

-- Create a file/folder
function M.create(path)
    path = vim.trim(path)
    if path == '' then
        vim.notify('Type a path in the search bar first', vim.log.levels.WARN)
        return
    end

    -- A trailing slash means folder (not file)
    if path:sub(-1) == '/' then
        vim.fn.mkdir(path, 'p')
        vim.notify('Created folder ' .. path)
        return
    end

    vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
    M.open(path, { how = 'edit' })
end

return M
