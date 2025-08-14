local M = {}

local ns_id = vim.api.nvim_create_namespace("Hexcolor")

function M.setup()
    vim.cmd([[
        augroup HexcolorHighlight
        autocmd!
        autocmd BufEnter,BufWritePost,TextChanged,TextChangedI * lua require('hexcolor').refresh()
        augroup END
    ]])

    vim.api.nvim_create_user_command('HexcolorRefresh', function()
        M.refresh()
    end, { desc = 'Refresh hex colour highlighting' })

    vim.api.nvim_create_user_command('HexcolorToggle', function()
        local bufnr = vim.api.nvim_get_current_buf()
        local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns_id, 0, -1, {})

        if #marks > 0 then
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
            print("Hex colour highlighting disabled")
        else
            M.refresh()
            print("Hex colour highlighting enabled")
        end
    end, { desc = 'Toggle hex colour highlighting' })
end

function M.refresh()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_get_option_value("modifiable", { buf = bufnr }) then
        M.highlight_hexcolors(bufnr)
    end
end

-- Normalize to #RRGGBB format
local function hexcolor(hex)
    if #hex == 4 then -- #RGB -> #RRGGBB
        return "#" .. hex:sub(2,2):rep(2)
                   .. hex:sub(3,3):rep(2)
                   .. hex:sub(4,4):rep(2)
    elseif #hex == 9 then -- #RRGGBBAA -> #RRGGBB (strip alpha)
        return "#" .. hex:sub(2,7)
    end
    return "#" .. hex
end

-- Calculate luminance and return appropriate foreground color
local function get_contrast_color(hex_color)
    -- Remove # and convert to numbers
    local hex = hex_color:sub(2)
    local r = tonumber(hex:sub(1,2), 16) / 255
    local g = tonumber(hex:sub(3,4), 16) / 255
    local b = tonumber(hex:sub(5,6), 16) / 255

    -- Calculate relative luminance using sRGB formula
    local function gamma_correct(c)
        if c <= 0.03928 then
            return c / 12.92
        else
            return ((c + 0.055) / 1.055) ^ 2.4
        end
    end

    local luminance = 0.2126 * gamma_correct(r) + 0.7152 * gamma_correct(g) + 0.0722 * gamma_correct(b)

    -- Return white text for dark backgrounds, black text for light backgrounds
    return luminance > 0.5 and "#000000" or "#ffffff"
end

-- Get all the instances of hex colors in a line
local function get_colors(line)
    local results = {}
    for s, hex, e in line:gmatch("()#(%x%x%x%x?%x?%x?%x?%x?)()%f[%W]") do
        local hex_len = #hex
        -- Only accept valid hex colour lengths: 3, 6, or 8 characters
        if hex_len == 3 or hex_len == 6 or hex_len == 8 then
            table.insert(results, { s, e, hexcolor(hex) })
        end
    end
    return results
end

function M.highlight_hexcolors(bufnr)
    -- Clear existing highlights
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    local created_hls = {}
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    for i, line in ipairs(lines) do
        for _, match in ipairs(get_colors(line)) do
            local s, e, color = match[1], match[2], match[3]
            local hl_name = "Hex_" .. color:sub(2)
            local fg_color = get_contrast_color(color)

            -- Create highlight group if it doesn't exist
            if not created_hls[hl_name] then
                vim.api.nvim_set_hl(0, hl_name, { bg = color, fg = fg_color })
                created_hls[hl_name] = true
            end

            -- Hightlight the text
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, s - 1, {
                end_row = i - 1,
                end_col = e - 1,
                hl_group = hl_name,
            })
        end
    end
end

return M
