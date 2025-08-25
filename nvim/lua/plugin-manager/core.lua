local M = {}

M.plugins = {}
M.errors = {}
M.error_messages = {}

function M.check_for_plugins()
    local ls_path = os.getenv("HOME")..'/.config/nvim/lua'

    -- Get all the plugins in the plugins folder
    M.plugins = {}
    local ls = io.popen('ls -d '..ls_path..'/*/'):read('*a')

    for path in string.gmatch(ls, "[^\n]*") do
        if path ~= '' then
            local folder_name = path:match("[^/]*/[^/]*$")
            folder_name = string.sub(folder_name, 1, string.len(folder_name)-1)

            -- Don't load the plugin-manager again (creating a loop)
            if folder_name ~= 'plugin-manager' then

                -- Check if there is a init.lua file in the folder
                -- To check if its a plugin or just a random folder
                local files_in_folder = io.popen('ls -d '..ls_path..'/'..folder_name..'/*'):read('*a')
                local init_file = files_in_folder:match(".*init.lua")
                if init_file ~= nil then
                    table.insert(M.plugins, folder_name)
                end
            end
        end
    end
end

function M.load_plugins()

    M.errors = {}
    M.error_messages = {}

    -- Load the plugins
    for i=1,#M.plugins,1 do
        local module
        local pass, response = pcall(function()
            module = require(M.plugins[i])
        end)
        if not pass then
            -- Error when loading
            table.insert(M.errors, M.plugins[i])
            table.insert(M.error_messages, response)
        else
            -- Run the setup function for the module
            local pass, response = pcall(function() module.setup() end)
            if not pass then
                table.insert(M.errors, M.plugins[i])
                table.insert(M.error_messages, response)
            end
        end
    end

    -- Error message on launch
    if #M.errors == 1 then
        print('Error while loading plugin:', M.errors[1])
    elseif #M.errors > 1 then
        print('Error while loading '..#M.errors..' plugins')
    end
end

return M
