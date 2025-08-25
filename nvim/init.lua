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

vim.keymap.set('v', '<TAB>', '>gv', { silent = true, desc = "Indent selection" })       -- Tab to indent selected text
vim.keymap.set('v', '<S-TAB>', '<gv', { silent = true, desc = "Outdent selection" })    -- Shift+Tab to outdent selected text

require('plugin-manager').setup()
