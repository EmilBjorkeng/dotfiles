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

set.splitright = true
set.splitbelow = true

set.termguicolors = true
vim.cmd.colorscheme('theme')

require('config.filetypes')
require('config.keymaps')
require('config.lazy')
