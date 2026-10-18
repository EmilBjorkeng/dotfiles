local set = vim.opt

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

set.statusline = '%m%r %f %y %=Ln %l, Col %v   %P '

-- Text
set.tabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.wrap = false

-- Number Column
set.number = true
set.relativenumber = true

-- Window splitting
set.splitright = true
set.splitbelow = true

-- Searching
set.ignorecase = true
set.smartcase = true

-- Scrolling
set.scrolloff = 8
set.sidescrolloff = 8

-- Safety
set.undofile = true
set.confirm = true

-- Spelling
set.spelllang = { 'en_gb' }

-- Theme
set.termguicolors = true
vim.cmd.colorscheme('theme')

require('config.filetypes')
require('config.keymaps')
require('config.autocmds')
require('config.lazy')
