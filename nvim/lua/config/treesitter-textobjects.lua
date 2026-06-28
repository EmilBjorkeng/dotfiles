local M = {}

function M.setup()
    require("nvim-treesitter-textobjects").setup({
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["ab"] = "@block.outer",
                ["ib"] = "@block.inner",
            },
            selection_modes = {
                ["@function.outer"] = "V",
                ["@class.outer"]    = "V",
                ["@block.outer"]    = "V",
                ["@parameter.outer"] = "v",
            },
            include_surrounding_whitespace = false,
        },

        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                ["]f"] = "@function.outer",
                ["]c"] = "@class.outer",
                ["]a"] = "@parameter.inner",
                ["]b"] = "@block.outer",
            },
            goto_next_end = {
                ["]F"] = "@function.outer",
                ["]C"] = "@class.outer",
                ["]A"] = "@parameter.inner",
            },
            goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[c"] = "@class.outer",
                ["[a"] = "@parameter.inner",
                ["[b"] = "@block.outer",
            },
            goto_previous_end = {
                ["[F"] = "@function.outer",
                ["[C"] = "@class.outer",
                ["[A"] = "@parameter.inner",
            },
        },

        swap = {
            enable = true,
            swap_next     = { ["<leader>sn"] = "@parameter.inner" },
            swap_previous = { ["<leader>sp"] = "@parameter.inner" },
        },
    })

    local repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
    vim.keymap.set({ "n", "x", "o" }, ";", repeat_move.repeat_last_move)
    vim.keymap.set({ "n", "x", "o" }, ",", repeat_move.repeat_last_move_opposite)
end

return M
