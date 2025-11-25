local diff = require('git-status.diff')

local M = {}

local git_signs_group = vim.api.nvim_create_augroup("GitSignsDynamic", { clear = true })
local enabled = true

local git_signs = {
    added = "+",
    modified = "~",
    deleted = "-",
    untracked = "?",

    deleted_added = "+-",
    deleted_modified = "~-",
    deleted_untracked = "?-",
}
local lsp_signs = {
    ERROR = "E",
    WARN = "W",
    INFO = "I",
    HINT = "H",
}
local sign_priority = 15

local severity_map = {
  [1] = "ERROR",
  [2] = "WARN",
  [3] = "INFO",
  [4] = "HINT",
}

local function get_combined_sign(line_num, status)
    local sign_name = "GitLine" .. status:gsub("^%l", string.upper)

    local diagnostics = vim.diagnostic.get(0, { lnum = line_num - 1 })
    if diagnostics[1] then
        local severity = severity_map[diagnostics[1].severity]
        return sign_name .. '_' .. severity
    end

    return sign_name
end


function M.clear_git_signs()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.fn.sign_unplace("git_lines", { buffer = bufnr })
end

function M.update_git_signs()
    local bufnr = vim.api.nvim_get_current_buf()
    local line_status = diff.get_git_diff()

    vim.fn.sign_unplace("git_lines", { buffer = bufnr })

    for line_num, status in pairs(line_status) do
        local sign_name = get_combined_sign(line_num, status)
        if type(sign_name) == "string" and #sign_name > 0 then
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            if line_num > 0 and line_num <= line_count then
                vim.fn.sign_place(0, "git_lines", sign_name, bufnr, { lnum = line_num, priority = 10 })
            end
        end
    end
end

function M.define_combined_signs()
    -- Pure git signs
    for git_status, symbol in pairs(git_signs) do
        local highlight = "DiffChange"
        if git_status == "added" then highlight = "DiffAdd"
        elseif git_status == "deleted" then highlight = "DiffDelete"
        elseif git_status == "untracked" then highlight = "Comment"

        elseif git_status == "deleted_added" then highlight = "DiffDelete"
        elseif git_status == "deleted_modified" then highlight = "DiffDelete"
        elseif git_status == "deleted_untracked" then highlight = "DiffDelete"
        end

        local sign_name = "GitLine" .. git_status:gsub("^%l", string.upper)
        vim.fn.sign_define(sign_name, {
            text = symbol,
            texthl = highlight,
            priority = sign_priority
        })
    end

    -- Combined git + LSP
    for git_status, git_symbol in pairs(git_signs) do
        for lsp_status, lsp_symbol in pairs(lsp_signs) do
            local highlight = "DiagnosticSign" .. lsp_status:gsub("^%l", string.upper)
            local sign_name = "GitLine" .. git_status:gsub("^%l", string.upper)
            vim.fn.sign_define(sign_name .. "_" .. lsp_status, {
                -- text = lsp_symbol .. git_symbol,
                text = git_symbol,
                texthl = highlight,
                priority = sign_priority
            })
        end
    end
end

function M.enable_git_status()
    vim.api.nvim_clear_autocmds({ group = git_signs_group })

    -- Clear on typing (Same effect as LSP)
    -- Makes it less distracting when typing
    vim.api.nvim_create_autocmd("TextChangedI", {
        group = git_signs_group,
        callback = M.clear_git_signs,
    })

    -- Update on buffer enter, after writing, after leaving insert mode and after text changes in normal mode
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
        group = git_signs_group,
        callback = M.update_git_signs,
    })

    -- Update when LSP updates (to get the correct combinations)
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = git_signs_group,
        callback = function()
            if vim.fn.mode() ~= "i" then
                M.update_git_signs()
            end
        end,
    })

    M.update_git_signs()
end

function M.disable_git_status()
    vim.api.nvim_clear_autocmds({ group = git_signs_group })
    M.clear_git_signs()
end

function M.toggle_git_signs()
    if enabled then
        M.disable_git_status()
        enabled = false
        print("Git status disabled")
    else
        M.enable_git_status()
        enabled = true
        print("Git status enabled")
    end
end

return M
