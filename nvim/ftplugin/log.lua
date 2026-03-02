vim.api.nvim_set_hl(0, 'LogBracket', { fg = '#61808F' })
vim.fn.matchadd('LogBracket', '\\[\\zs.\\{-}\\ze\\]')

vim.api.nvim_set_hl(0, 'LogInfo', { fg = '#4FC3F7' })
vim.fn.matchadd('LogInfo', [[\[\zsINFO\ze]])

vim.api.nvim_set_hl(0, 'LogWarning', { fg = '#FFB300' })
vim.fn.matchadd('LogWarning', [[\[\zsWARNING\ze]])

vim.api.nvim_set_hl(0, 'LogError', { fg = '#F44336' })
vim.fn.matchadd('LogError', [[\[\zsERROR\ze]])

vim.api.nvim_set_hl(0, 'LogCritical', { fg = '#D32F2F', bold = true })
vim.fn.matchadd('LogCritical', [[\[\zsCRITICAL\ze]])

vim.api.nvim_set_hl(0, 'LogDebug', { fg = '#66BB6A' })
vim.fn.matchadd('LogDebug', [[\[\zsDEBUG\ze]])

vim.api.nvim_set_hl(0, 'LogIP', { fg = '#9C5AA0' })
vim.fn.matchadd('LogIP', [[\v\d{1,3}(\.\d{1,3}){3}(:\d+)?]])
