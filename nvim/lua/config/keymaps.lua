local map = vim.keymap.set

-- Clipboard
map('v', '<C-c>', '"+y', { silent = true, desc = 'Copy to clipboard' })
map('v', '<C-x>', '"+d', { silent = true, desc = 'Cut to clipboard' })

-- Indenting
map('v', '<TAB>', '>gv', { silent = true, desc = 'Indent selection' })
map('v', '<S-TAB>', '<gv', { silent = true, desc = 'Outdent selection' })

-- Navigation (Scout)
map('n', '<leader>ff', '<cmd>Scout Files<cr>', { desc = 'Find file' })
map('n', '<leader>fg', '<cmd>Scout Live_Grep<cr>', { desc = 'Find in files (grep)' })
map('n', '<leader>fo', '<cmd>Scout Oldfiles<cr>', { desc = 'Find old files' })
map('n', '<leader>fb', '<cmd>Scout Buffers<cr>', { desc = 'Find buffer' })

map('n', '<leader><leader>', '<cmd>Scout Buffers<cr>', { desc = 'Switch buffer' })

-- Buffers
map('n', '<leader>bd', function()
    require('scout.utils').delete_buffer(vim.api.nvim_get_current_buf())
end, { desc = 'Delete buffer, keep window' })

-- Windows
map('n', '<leader>wv', '<cmd>vsplit<cr>', { desc = 'Split vertically' })
map('n', '<leader>ws', '<cmd>split<cr>', { desc = 'Split horizontally' })
map('n', '<leader>wc', '<cmd>close<cr>', { desc = 'Close window' })
map('n', '<leader>wo', '<cmd>only<cr>', { desc = 'Close other windows' })
map('n', '<leader>w=', '<C-w>=', { desc = 'Equalise windows' })
map('n', '<leader>wx', '<C-w>x', { desc = 'Swap with next window' })

map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Taller window' })
map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Shorter window' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Narrower window' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Wider window' })

-- Searching
map('n', '<Esc>', '<cmd>nohlsearch<cr><Esc>', { desc = 'Clear search highlight' })
