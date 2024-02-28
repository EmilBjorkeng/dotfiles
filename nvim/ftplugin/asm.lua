local set = vim.opt

set.tabstop=2
set.shiftwidth=2
set.expandtab=true

---------------------------
--  Syntax highlighting  --
---------------------------

-- Base Colour
vim.cmd([[highlight baseColour ctermfg=Cyan]])
vim.fn.matchadd('baseColour', '.')

-- Comments
vim.cmd([[highlight commentColour ctermfg=Grey]])
vim.fn.matchadd('commentColour', ';\\+.*')

-- Quotes
vim.cmd([[highlight quoteColour ctermfg=LightMagenta]])
vim.fn.matchadd('quoteColour', '".\\{-}"')
vim.fn.matchadd('quoteColour', "'.\\{-}'")

-- Commands
vim.cmd([[highlight commandColour ctermfg=blue]])
vim.fn.matchadd('commandColour', '^\\s\\+\\w\\+\\|^\\w\\+')

-- Jump
vim.cmd([[highlight jumpColour ctermfg=Yellow]])
vim.fn.matchadd('jumpColour', '^\\<jmp\\>\\|^\\s\\+\\<jmp\\>')
vim.fn.matchadd('jumpColour', '^\\<je\\>\\|^\\s\\+\\<je\\>')
vim.fn.matchadd('jumpColour', '^\\<jne\\>\\|^\\s\\+\\<jne\\>')
vim.fn.matchadd('jumpColour', '^\\<jg\\>\\|^\\s\\+\\<jg\\>')
vim.fn.matchadd('jumpColour', '^\\<jge\\>\\|^\\s\\+\\<jge\\>')
vim.fn.matchadd('jumpColour', '^\\<jl\\>\\|^\\s\\+\\<jl\\>')
vim.fn.matchadd('jumpColour', '^\\<jle\\>\\|^\\s\\+\\<jle\\>')
vim.fn.matchadd('jumpColour', '^\\<ja\\>\\|^\\s\\+\\<ja\\>')
vim.fn.matchadd('jumpColour', '^\\<jae\\>\\|^\\s\\+\\<jae\\>')
vim.fn.matchadd('jumpColour', '^\\<jb\\>\\|^\\s\\+\\<jb\\>')
vim.fn.matchadd('jumpColour', '^\\<jbe\\>\\|^\\s\\+\\<jbe\\>')
vim.fn.matchadd('jumpColour', '^\\<jc\\>\\|^\\s\\+\\<jc\\>')
vim.fn.matchadd('jumpColour', '^\\<jnc\\>\\|^\\s\\+\\<jnc\\>')
vim.fn.matchadd('jumpColour', '^\\<jz\\>\\|^\\s\\+\\<jz\\>')
vim.fn.matchadd('jumpColour', '^\\<jnz\\>\\|^\\s\\+\\<jnz\\>')
vim.fn.matchadd('jumpColour', '^\\<js\\>\\|^\\s\\+\\<js\\>')
vim.fn.matchadd('jumpColour', '^\\<jns\\>\\|^\\s\\+\\<jns\\>')
vim.fn.matchadd('jumpColour', '^\\<jp\\>\\|^\\s\\+\\<jp\\>')
vim.fn.matchadd('jumpColour', '^\\<jnp\\>\\|^\\s\\+\\<jnp\\>')
vim.fn.matchadd('jumpColour', '^\\<jo\\>\\|^\\s\\+\\<jo\\>')
vim.fn.matchadd('jumpColour', '^\\<jno\\>\\|^\\s\\+\\<jno\\>')

-- Label
vim.cmd([[highlight labelColour ctermfg=White]])
vim.fn.matchadd('labelColour', '^\\w\\+:')

-- Global (_start)
vim.cmd([[highlight globalColour ctermfg=Yellow]])
vim.fn.matchadd('globalColour', '^global')

-- Secrion (.text)
vim.cmd([[highlight sectiontypeColour ctermfg=Yellow]])
vim.fn.matchadd('sectiontypeColour', '^section .*')

-- Push/Pop
vim.cmd([[highlight pushColour ctermfg=DarkYellow]])
vim.fn.matchadd('pushColour', '^\\<push\\>\\|^\\s\\+\\<push\\>')
vim.fn.matchadd('pushColour', '^\\<pop\\>\\|^\\s\\+\\<pop\\>')

-- Numbers
vim.cmd([[highlight numberColour ctermfg=Magenta]])
vim.fn.matchadd('numberColour', '0x\\S*\\|\\d')

-- 8 bit register
vim.cmd([[highlight registerColour8 ctermfg=Red]])
vim.fn.matchadd('registerColour8', '\\<al\\>')
vim.fn.matchadd('registerColour8', '\\<bl\\>')
vim.fn.matchadd('registerColour8', '\\<cl\\>')
vim.fn.matchadd('registerColour8', '\\<dl\\>')

-- 16 bit register
vim.cmd([[highlight registerColour16 ctermfg=Red]])
vim.fn.matchadd('registerColour16', '\\<ax\\>')
vim.fn.matchadd('registerColour16', '\\<bx\\>')
vim.fn.matchadd('registerColour16', '\\<cx\\>')
vim.fn.matchadd('registerColour16', '\\<dx\\>')
vim.fn.matchadd('registerColour16', '\\<si\\>')
vim.fn.matchadd('registerColour16', '\\<di\\>')
vim.fn.matchadd('registerColour16', '\\<bp\\>')
vim.fn.matchadd('registerColour16', '\\<sp\\>')

-- 32 bit register
vim.cmd([[highlight registerColour32 ctermfg=Red]])
vim.fn.matchadd('registerColour32', '\\<eax\\>')
vim.fn.matchadd('registerColour32', '\\<ebx\\>')
vim.fn.matchadd('registerColour32', '\\<ecx\\>')
vim.fn.matchadd('registerColour32', '\\<edx\\>')
vim.fn.matchadd('registerColour32', '\\<esi\\>')
vim.fn.matchadd('registerColour32', '\\<edi\\>')
vim.fn.matchadd('registerColour32', '\\<ebp\\>')
vim.fn.matchadd('registerColour32', '\\<esp\\>')

-- 64 bit registers
vim.cmd([[highlight registerColour64 ctermfg=Red]])
vim.fn.matchadd('registerColour64', '\\<rax\\>')
vim.fn.matchadd('registerColour64', '\\<rbx\\>')
vim.fn.matchadd('registerColour64', '\\<rcx\\>')
vim.fn.matchadd('registerColour64', '\\<rdx\\>')
vim.fn.matchadd('registerColour64', '\\<rsi\\>')
vim.fn.matchadd('registerColour64', '\\<rdi\\>')
vim.fn.matchadd('registerColour64', '\\<rbp\\>')
vim.fn.matchadd('registerColour64', '\\<rsp\\>')
vim.fn.matchadd('registerColour64', '\\<r8\\>')
vim.fn.matchadd('registerColour64', '\\<r9\\>')
vim.fn.matchadd('registerColour64', '\\<r10\\>')
vim.fn.matchadd('registerColour64', '\\<r11\\>')
vim.fn.matchadd('registerColour64', '\\<r12\\>')
vim.fn.matchadd('registerColour64', '\\<r13\\>')
vim.fn.matchadd('registerColour64', '\\<r14\\>')
vim.fn.matchadd('registerColour64', '\\<r15\\>')
