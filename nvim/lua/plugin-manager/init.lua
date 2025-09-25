local plugins = require("plugins")
local core = require("plugin-manager.core")
local commands = require("plugin-manager.commands")

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
M.errors = {}

M.setup = function()
    for _, plugin in ipairs(plugins) do
        M.loaded[plugin.module] = false
    end

    vim.api.nvim_set_hl(0, "PluginError", { fg = "#d32d33" })
    vim.api.nvim_set_hl(0, "PluginCheck", { fg = "#068515" })

    commands.setup()
    core.load_all()
end

return M
