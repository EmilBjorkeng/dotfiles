local set = vim.opt

set.tabstop=4
set.shiftwidth=4
set.expandtab=true
set.wrap = false
set.statusline = "%m%r %F %y %=Ln %l, Col %c   %P "

set.termguicolors = true
vim.cmd.colorscheme('theme')

vim.keymap.set('v', '<C-c>', '"+y', { noremap = true, silent = true, nowait = true, expr = false }) -- Copy to clipboard
vim.keymap.set('v', '<C-x>', '"+d', { noremap = true, silent = true, nowait = true, expr = false }) -- Cut to clipboard

require('plugin-manager').setup()
