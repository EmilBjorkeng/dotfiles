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

    -- Already loaded, run callback immediately
    if pm.loaded[plugin.module] then
        if callback then callback() end
        return
    end

    -- Already loading, queue callback
    if pm.loading[plugin.module] then
        pm.waiting[plugin.module] = pm.waiting[plugin.module] or {}
        table.insert(pm.waiting[plugin.module], callback)
        return
    end

    local install_path = plugin.repo and (fn.stdpath('data') .. '/plugins/' .. plugin.module)

    local function finish()
        if plugin.repo then
            vim.opt.rtp:append(install_path)
        end

        local mod = M.safe_require(plugin.module)
        if mod then
            if plugin.config == true and mod.setup then
                mod.setup()
            elseif type(plugin.config) == 'function' then
                plugin.config(plugin)
            end
        end

        pm.loaded[plugin.module] = true
        pm.loading[plugin.module] = nil

        if pm.waiting[plugin.module] then
            for _, cb in ipairs(pm.waiting[plugin.module]) do
                if cb then cb() end
            end
        end
        pm.waiting[plugin.module] = nil

        if callback then callback() end
    end

    if plugin.repo then
        pm.loading[plugin.module] = true
        if fn.isdirectory(install_path) == 0 then
            -- Clone repo
            fn.jobstart({
                'git', 'clone', '--depth', '1',
                'https://github.com/' .. plugin.repo .. '.git', install_path
            }, {
                on_exit = function(_, code)
                    if code == 0 then
                        vim.schedule(finish)
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
                        vim.schedule(finish)
                    else
                        vim.notify('Update failed: ' .. plugin.repo, vim.log.levels.ERROR)
                    end
                end
            })
        end
    else
        -- No repo, skip to finish
        finish()
    end
end

function M.load_with_deps(plugin)
    local pm = require("plugin-manager")

    local deps = plugin.dependencies or {}
    local waiting = #deps

    -- No dependencies
    if waiting == 0 then
        return M.load_plugin(plugin)
    end

    local function dep_done()
        waiting = waiting - 1
        if waiting == 0 then
            -- All deps done, load main plugin
            M.load_plugin(plugin)
        end
    end

    for _, dep in ipairs(deps) do
        local dep_spec = pm.lookup[dep]
        if dep_spec then
            M.load_plugin(dep_spec, dep_done)
        else
            vim.notify('Missing dependency: ' .. dep, vim.log.levels.ERROR)
            return
        end
    end
end

return M
