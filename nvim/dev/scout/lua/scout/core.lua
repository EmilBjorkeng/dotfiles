local menu = require('scout.menu')

local M = {}

M.start_in_search = false

function M.scout(type)
    require('scout.' .. type).scout()

    if M.start_in_search then
        -- Start in the search bar
        menu.start_search()
    end
end

return M
