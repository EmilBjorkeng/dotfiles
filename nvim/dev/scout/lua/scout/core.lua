local menu = require('scout.menu')
local open = require('scout.open')

local M = {}

M.start_in_search = false

function M.scout(type)
    open.remember_origin()
    require('scout.' .. type).scout()

    if M.start_in_search then
        -- Start in the search bar
        menu.start_search()
    end
end

return M
