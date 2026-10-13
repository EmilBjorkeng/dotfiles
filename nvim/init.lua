vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

local set = vim.opt
set.tabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.wrap = false
set.statusline = '%m%r %F %y %=Ln %l, Col %c   %P '
vim.opt.number = true
set.relativenumber = true

set.termguicolors = true
vim.cmd.colorscheme('theme')

vim.keymap.set('v', '<C-c>', '"+y', { noremap = true, silent = true, nowait = true, expr = false }) -- Copy to clipboard
vim.keymap.set('v', '<C-x>', '"+d', { noremap = true, silent = true, nowait = true, expr = false }) -- Cut to clipboard

vim.keymap.set('v', '<TAB>', '>gv', { silent = true, desc = 'Indent selection' })    -- Tab to indent selected text
vim.keymap.set('v', '<S-TAB>', '<gv', { silent = true, desc = 'Outdent selection' }) -- Shift+Tab to outdent selected text

-- Navigation
vim.keymap.set('n', '<leader>ff', '<cmd>Scout Files<cr>', { desc = 'Find file' })
vim.keymap.set('n', '<leader>fg', '<cmd>Scout Live_Grep<cr>', { desc = 'Find in files (grep)' })
vim.keymap.set('n', '<leader>fo', '<cmd>Scout Oldfiles<cr>', { desc = 'Find old files' })
vim.keymap.set('n', '<leader>fb', '<cmd>Scout Buffers<cr>', { desc = 'Find buffer' })

vim.keymap.set('n', '<leader><leader>', '<cmd>Scout Buffers<cr>', { desc = 'Switch buffer' })

require('config.filetypes')
require('config.lazy')
