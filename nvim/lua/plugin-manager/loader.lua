local M = {}

function M.safe_require(module)
    local ok, mod = pcall(require, module)
    if not ok then
        vim.notify("Failed to load module: " .. module, vim.log.levels.ERROR)
        vim.notify("Error: " .. mod, vim.log.levels.ERROR)
        require('plugin-manager').errors[module] = mod
        return nil
    end
    return mod
end

function M.load_plugin(plugin)
    local pm = require("plugin-manager")
    if pm.loaded[plugin.module] then return end

    local mod = M.safe_require(plugin.module)
    if not mod then return end

    if plugin.config == true and mod.setup then
        mod.setup()
    elseif type(plugin.config) == "function" then
        plugin.config(plugin)
    end

    pm.loaded[plugin.module] = true
end

function M.load_with_deps(plugin)
    local pm = require("plugin-manager")

    if plugin.dependencies then
        for _, dep in ipairs(plugin.dependencies) do
            local dep_spec = pm.lookup[dep:lower()]
            if dep_spec then
                M.load_plugin(dep_spec)
            else
                vim.notify("Dependency not found: " .. dep, vim.log.levels.WARN)
            end
        end
    end
    M.load_plugin(plugin)
end

return M
