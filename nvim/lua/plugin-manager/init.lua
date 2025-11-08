local core = require("plugin-manager.core")
local commands = require("plugin-manager.commands")

local M = {}

M.plugins = require("plugins")
M.lookup = {}
M.loaded = {}
M.errors = {}
M.waiting = {}

M.setup = function()
    vim.api.nvim_set_hl(0, "PluginError", { fg = "#d32d33" })
    vim.api.nvim_set_hl(0, "PluginCheck", { fg = "#068515" })

    -- Add module, name and/or repo as the keys to the lookup table
    -- As well as adding the dependencies
    for _, plugin in ipairs(M.plugins) do
        if plugin.module then M.lookup[plugin.module] = plugin end
        if plugin.name then M.lookup[plugin.name] = plugin end
        if plugin.repo then M.lookup[plugin.repo] = plugin end

        if plugin.dependencies then
            for _, dep in ipairs(plugin.dependencies) do
                if type(dep) == 'table' then
                    -- Table deps
                    if dep.module and not M.lookup[dep.module] then M.lookup[dep.module] = dep end
                    if dep.name and not M.lookup[dep.name] then M.lookup[dep.name] = dep end
                    if dep.repo and not M.lookup[dep.repo] then M.lookup[dep.repo] = dep end
                else
                    -- String deps
                    if not M.lookup[dep] then
                        M.lookup[dep] = {}
                        if string.find(dep, '/', 1, true) then
                            M.lookup[dep].repo = dep
                        else
                            M.lookup[dep].module = dep
                        end
                    end
                end
            end
        end
    end

    -- Add require name to all the plugins
    for _, plugin in pairs(M.lookup) do
        if not plugin.require_name then
            local repo_name = plugin.repo and plugin.repo:match('.*/(.*)'):gsub('-', '_')
            plugin.require_name = plugin.module or plugin.name or repo_name
            M.lookup[plugin.require_name] = plugin
        end
    end

    -- Make plugin.dependencies point to the table instead of just a name
    for _, plugin in ipairs(M.plugins) do
        local deps = {}
        if plugin.dependencies then
            for _, dep in ipairs(plugin.dependencies) do
                local name = dep.module or dep.name or dep.repo or dep
                table.insert(deps, name)
            end

            plugin.dependencies = {}
            for _, name in ipairs(deps) do
                table.insert(plugin.dependencies, M.lookup[name])
            end
        end
    end

    commands.setup()
    core.load_all()
end

return M
