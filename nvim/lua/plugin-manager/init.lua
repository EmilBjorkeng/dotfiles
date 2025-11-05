local plugins = require("plugins")
local core = require("plugin-manager.core")
local commands = require("plugin-manager.commands")

local M = {}

-- Build lookup table
local lookup = {}
for _, plugin in ipairs(plugins) do
    lookup[plugin.module] = plugin
end

M.plugins = plugins
M.lookup = lookup
M.loaded = {}
M.errors = {}

M.loading = {}
M.waiting = {}

M.setup = function()
    vim.api.nvim_set_hl(0, "PluginError", { fg = "#d32d33" })
    vim.api.nvim_set_hl(0, "PluginCheck", { fg = "#068515" })

    for _, plugin in ipairs(plugins) do
        local module = plugin.module
        M.loaded[module] = false
    end

    commands.setup()
    core.load_all()
end

return M
