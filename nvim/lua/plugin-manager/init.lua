local plugins = require("plugins")
local core = require("plugin-manager.core")

local M = {}

-- Build lookup table by module and name
local lookup = {}
for _, plugin in ipairs(plugins) do
    lookup[plugin.module] = plugin
    lookup[plugin.name:lower()] = plugin
end

M.plugins = plugins
M.lookup = lookup
M.loaded = {}

M.setup = function()
    core.load_all()
end

return M
