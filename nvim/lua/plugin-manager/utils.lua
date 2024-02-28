local M = {}
    
local errors = {}
local error_messages = {}

-- Plugin setup
function M.setup()
    local ls_path = os.getenv("HOME")..'/.config/nvim/lua' 

    -- Get all the plugins in the plugins folder
    local plugins = {}
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
                    table.insert(plugins, folder_name)
                end
            end
        end
    end
    
    -- Load the plugins
    for i=1,#plugins,1 do
        local module
        local pass, response = pcall(function()
            module = require(plugins[i]) 
        end)
        if not pass then
            -- Error when loading
            table.insert(errors, plugins[i])
            table.insert(error_messages, response)
            
            print('Error while loading plugin:', plugins[i])
            print('Message:', response)
        else
            -- Run the setup function for the module
            module.setup()
        end
    end

    -- Error message on launch
    if #errors == 1 then
        print('Error while loading plugin:', errors[0])
    elseif #errors > 1 then
        print('Error while loading '..#errors..' plugins')
    end
end

return M
