local M = {}

function M.setup()
    local ts = require("nvim-treesitter")

    local parsers = {
        "bash", "c", "cpp", "css", "diff",
        "html", "javascript", "jsdoc", "json",
        "lua", "luadoc", "markdown", "markdown_inline",
        "python", "query", "regex", "toml",
        "tsx", "typescript", "vim", "vimdoc",
        "yaml", "rust",
    }

    for _, parser in ipairs(parsers) do
        ts.install(parser)
    end

    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt.foldenable = false
end

return M
