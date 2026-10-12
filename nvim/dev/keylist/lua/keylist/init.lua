local M = {}

-- Replace the leader prefix in a raw lhs with a "<leader>" label
local function readable_lhs(m)
    local raw = m.lhsraw or m.lhs
    local leaders = {
        { key = vim.g.mapleader or "\\", label = "<leader>" },
        { key = vim.g.maplocalleader or "\\", label = "<localleader>" },
    }

    for _, l in ipairs(leaders) do
        local key = vim.api.nvim_replace_termcodes(l.key, true, true, true)
        if key ~= "" and raw:sub(1, #key) == key then
            return l.label .. vim.fn.keytrans(raw:sub(#key + 1))
        end
    end

    return vim.fn.keytrans(raw)
end

local function mapping_info(m)
    if m.desc then
        return m.desc
    end
    if m.rhs and m.rhs ~= "" then
        return m.rhs
    end
    if m.callback then
        local src = debug.getinfo(m.callback, "S")
        if src.what == "C" then
            return "<C function>"
        end
        local file = (src.source:gsub("^@", ""))
        return "<Lua> " .. vim.fn.fnamemodify(file, ":~") .. ":" .. src.linedefined
    end
    return ""
end

-- :Keys [filter]   List keymaps, optionally filtered (case-insensitive)
-- :Keys! [filter]  Load all lazy-loaded plugins first, then list
local function list_keys(opts)
    if opts.bang and package.loaded["lazy"] then
        pcall(vim.cmd, "Lazy load all")
    end

    local filter = opts.args:lower()
    local lines = {}
    local modes = { "n", "x", "o", "i", "t", "c" }

    for _, mode in ipairs(modes) do
        local maps = vim.api.nvim_buf_get_keymap(0, mode)
        vim.list_extend(maps, vim.api.nvim_get_keymap(mode))

        for _, m in ipairs(maps) do
            if not m.lhs:find("<Plug>", 1, true) then
                local lhs = readable_lhs(m)
                local info = mapping_info(m)
                local scope = m.buffer ~= 0 and "[buf]" or ""
                local line = string.format("%-2s %-20s %-5s %s", mode, lhs, scope, info)
                if filter == "" or line:lower():find(filter, 1, true) then
                    table.insert(lines, line)
                end
            end
        end
    end

    if #lines == 0 then
        vim.notify("No keymaps found matching: " .. opts.args, vim.log.levels.INFO)
        return
    end

    table.sort(lines)

    vim.cmd("botright new")
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close keymap list" })
end

function M.setup()
    vim.api.nvim_create_user_command("Keys", list_keys, {
        nargs = "?",
        bang = true,
        desc = "List keymaps, optionally filtered",
    })
end

return M
