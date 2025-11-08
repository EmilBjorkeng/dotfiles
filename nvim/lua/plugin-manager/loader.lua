local M = {}

function M.safe_require(module)
    local ok, mod = pcall(require, module)
    if not ok then
        vim.schedule(function()
            vim.notify("Failed to load module: " .. module, vim.log.levels.ERROR)
            --vim.notify("Error: " .. mod, vim.log.levels.ERROR)
        end)
        require('plugin-manager').errors[module] = mod
        return nil
    end
    return mod
end

function M.load_plugin(plugin, callback)
    local pm = require("plugin-manager")
    local fn = vim.fn

    -- Already loaded
    if pm.loaded[plugin.require_name] then
        if callback then callback() end
        return
    end

    -- Already loading
    if pm.waiting[plugin.require_name] then
        if callback then
            table.insert(pm.waiting[plugin.require_name], callback)
        end
        return
    end

    pm.waiting[plugin.require_name] = {}

    local install_path = plugin.repo and (fn.stdpath('data') .. '/plugins/' .. plugin.repo:match('.*/(.*)'))

    -- Runs after git
    local function plugin_require()
        if plugin.repo then
            vim.opt.rtp:append(install_path)
            vim.cmd('runtime! plugin/**/*.lua')
        end

        local mod = M.safe_require(plugin.require_name)
        if mod then
            if plugin.config == true and mod.setup then
                mod.setup()
            elseif type(plugin.config) == 'function' then
                plugin.config(plugin)
            end
        end
        pm.loaded[plugin.require_name] = true

        -- Clear any waiting queue
        if pm.waiting[plugin.require_name] then
            for _, func in ipairs(pm.waiting[plugin.require_name]) do
                func()
            end
        end
        pm.waiting[plugin.require_name] = nil

        if callback then callback() end
    end

    if plugin.repo then
        if fn.isdirectory(install_path) == 0 then
            -- Clone repo
            fn.jobstart({
                'git', 'clone', '--depth', '1',
                'https://github.com/' .. plugin.repo .. '.git', install_path
            }, {
                on_exit = function(_, code)
                    if code == 0 then
                        vim.schedule(plugin_require)
                    else
                        vim.notify('Clone failed: ' .. plugin.repo, vim.log.levels.ERROR)
                    end
                end
            })
        else
            -- Pull repo
            fn.jobstart({
                'git', '-C', install_path, 'pull', '--ff-only'
            }, {
                on_exit = function(_, code)
                    if code == 0 then
                        vim.schedule(plugin_require)
                    else
                        vim.notify('Update failed: ' .. plugin.repo .. ', continuing with un-updated version', vim.log.levels.ERROR)
                        vim.schedule(plugin_require)
                    end
                end
            })
        end
    else
        plugin_require()
    end
end

function M.load_with_deps(plugin)
    local deps = plugin.dependencies

    -- Do deps
    if not deps then
        M.load_plugin(plugin)
        return
    end

    -- Plugin then deps
    if plugin.before_deps == true then
        M.load_plugin(plugin, function()
            for _, dep in ipairs(deps) do
                M.load_plugin(dep)
            end
        end)
        return
    end

    -- Deps then plugin
    local waiting = #deps
    for _, dep in ipairs(deps) do
        M.load_plugin(dep, function()
            waiting = waiting - 1
            if waiting == 0 then
                M.load_plugin(plugin)
            end
        end)
    end
end

return M
