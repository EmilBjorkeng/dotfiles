local lazy = require("plugin-manager.lazy")
local loader = require("plugin-manager.loader")

local M = {}

function M.load_all()
    local plugins = require('plugin-manager').plugins

    for _, plugin in ipairs(plugins) do
        if plugin.lazy then
            lazy.register(plugin, loader.load_with_deps)
        else
            loader.load_with_deps(plugin)
        end
    end
end

return M
