local M = {}

function M.register(plugin, loader_fn)
    local lazy = plugin.lazy
    if not lazy then return end

    -- Load on filetypes
    if lazy.ft then
        local fts = type(lazy.ft) == "table" and lazy.ft or { lazy.ft }
        vim.api.nvim_create_autocmd("FileType", {
            pattern = fts,
            callback = function() loader_fn(plugin) end,
        })
    end

    -- Load on events
    if lazy.event then
        local events = type(lazy.event) == "table" and lazy.event or { lazy.event }
        for _, ev in ipairs(events) do
            vim.api.nvim_create_autocmd(ev, {
                callback = function() loader_fn(plugin) end,
            })
        end
    end

    -- Load on commands
    if lazy.cmd then
        local cmds = type(lazy.cmd) == "table" and lazy.cmd or { lazy.cmd }
        for _, c in ipairs(cmds) do
            vim.api.nvim_create_user_command(c, function()
                loader_fn(plugin)
            end, {})
        end
    end
end

return M
