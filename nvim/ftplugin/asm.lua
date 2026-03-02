local set = vim.opt

set.tabstop=2
set.shiftwidth=2
set.expandtab=true

---------------------------
--  Syntax highlighting  --
---------------------------

-- Base Color
vim.api.nvim_set_hl(0, 'baseColor', {ctermfg='Cyan'})
vim.fn.matchadd('baseColor', '.')

-- Comments
vim.api.nvim_set_hl(0, 'commentColor', {ctermfg='Grey'})
vim.fn.matchadd('commentColor', ';.+')

-- Quotes
vim.api.nvim_set_hl(0, 'quoteColor', {ctermfg='LightMagenta'})
vim.fn.matchadd('quoteColor', '".-?"')
vim.fn.matchadd('quoteColor', "'.-?'")

-- Commands
vim.api.nvim_set_hl(0, 'commandColor', {ctermfg='Blue'})
vim.fn.matchadd('commandColor', '^%s*%w+')

-- Jump
vim.api.nvim_set_hl(0, 'jumpColor', {ctermfg='Yellow'})
local jumps = {
    'jmp','je','jne','jg','jge','jl','jle','ja','jae','jb','jbe',
    'jc','jnc','jz','jnz','js','jns','jp','jnp','jo','jno'
}
for _, j in ipairs(jumps) do
    vim.fn.matchadd('jumpColor', '^%s*<'..j..'>')
end

-- Label
vim.api.nvim_set_hl(0, 'labelColor', {ctermfg='White'})
vim.fn.matchadd('labelColor', '^%w+:')

-- Global (_start)
vim.api.nvim_set_hl(0, 'globalColor', {ctermfg='Yellow'})
vim.fn.matchadd('globalColor', '^global')

-- Secrion (.text)
vim.api.nvim_set_hl(0, 'sectiontypeColor', {ctermfg='Yellow'})
vim.fn.matchadd('sectiontypeColor', '^section .*')

-- Push/Pop
vim.api.nvim_set_hl(0, 'pushColor', {ctermfg='DarkYellow'})
vim.fn.matchadd('pushColor', '^%s*<(push|pop)>')

-- Numbers
vim.api.nvim_set_hl(0, 'numberColor', {ctermfg='Magenta'})
vim.fn.matchadd('numberColor', '0x%S*|%d')

-- 8 bit register
vim.api.nvim_set_hl(0, 'registerColor8', {ctermfg='Red'})
local r8 = {'al','bl','cl','dl'}
for _, reg in ipairs(r8) do
    vim.fn.matchadd('registerColor8', '<'..reg..'>')
end

-- 16 bit register
vim.api.nvim_set_hl(0, 'registerColor16', {ctermfg='Red'})
local r16 = {'ax','bx','cx','dx','si','di','bp','sp'}
for _, reg in ipairs(r16) do
    vim.fn.matchadd('registerColor16', '<'..reg..'>')
end

-- 32 bit register
vim.api.nvim_set_hl(0, 'registerColor32', {ctermfg='Red'})
local r32 = {'eax','ebx','ecx','edx','esi','edi','ebp','esp'}
for _, reg in ipairs(r32) do
    vim.fn.matchadd('registerColor32', '<'..reg..'>')
end

-- 64 bit registers
vim.api.nvim_set_hl(0, 'registerColor64', {ctermfg='Red'})
local r64 = {
    'rax','rbx','rcx','rdx','rsi','rdi','rbp','rsp',
    'r8','r9','r10','r11','r12','r13','r14','r15'
}
for _, reg in ipairs(r64) do
    vim.fn.matchadd('registerColor64', '<'..reg..'>')
end
