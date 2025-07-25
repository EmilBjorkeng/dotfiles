local set = vim.opt

set.tabstop=4
set.shiftwidth=4
set.expandtab=true

vim.keymap.set('v', '<C-c>', '"+y', { noremap = true, silent = true, nowait = true, expr = false })

require('plugin-manager').setup()
