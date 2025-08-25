-- Clear existing highlights
vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') == 1 then
  vim.cmd('syntax reset')
end

-- Set colorscheme name and background
vim.g.colors_name = 'theme'
vim.o.background = 'dark'

-- Helper function to set highlights
local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local colors = {
    bg = '#0c0c0c',             -- Darkgrey for background
    fg = '#d4d4d4',             -- Lightgrey for text
    comment = '#3B8d68',        -- Green for comments
    string = '#ce9178',         -- Orange for strings
    number = '#99ba81',         -- Purple for numbers
    keyword = '#ab67b1',        -- Purple for keywords
    func = "#f3dc77",           -- Yellow for functions
    types = '#636fda',          -- Blue for types
    operator = '#A7ADE1',       -- Lightblue for operator
    special = '#d16969',        -- Red-orange for special chars(\n)
    delimiter = "#FFE15B",      -- Yellow for delimiter
    linenumber = '#858585',     -- Grey for line numbers (:set number)
    statusline = '#d4d4d4',     -- Light grey for the status line
    inactive = '#858585',       -- Light grey for the status line
    highlight = '#ffff00',      -- Yellow for highlight
    errorred = "#ff2222",       -- Red for errors
    warningred = '#bd7979',     -- A little softer red for warnings
    hintblue = '#9acbec',       -- Blue for hints
    subtlehl = '#191520',       -- Very dark violet for subtle highlights
    class = '#4ec9b0',          -- Turquoise for classes
    enum = '#4352dc',           -- Blue for enum members

    white = '#ffffff',          -- White - For pure white elements
    black = '#000000',          -- Black - For pure black elements
    grey = '#959595',           -- Grey - Noticable against both fg and bg
    darkgrey = '#454545',       -- Darkgrey - Subtly agains bg
    green = '#068515',          -- Green - Good things (Add)
    red = '#d32d33',            -- Red - Bad, but not errorred bad (Delete)
    greyblue = '#394b70',       -- Greyblue - Difftext
    cyan = '#7498A9',           -- Cyan - Used for directories
}

-- Base colors
hi('Normal', { fg = colors.fg, bg = colors.bg })
hi('NormalFloat', { fg = colors.fg, bg = colors.bg })

-- Syntax highlighting
hi('Comment', { fg = colors.comment, italic = true })       -- Comment (this)
hi('Constant', { fg = colors.types })                       -- NULL, EXIT_SUCCESS
hi('String', { fg = colors.string })                        -- "String"
hi('Character', { fg = colors.string })                     -- 'c', 'h'
hi('Number', { fg = colors.number })                        -- 1, 2, 3
hi('Boolean', { fg = colors.keyword })                      -- true, false
hi('Float', { fg = colors.number })                         -- 2.7, 5.6

hi('Identifier', { fg = colors.types })                     -- this, let, </>
hi('Function', { fg = colors.func })                        -- Functions

hi('Statement', { fg = colors.keyword })                    -- local, return, do
hi('Conditional', { fg = colors.keyword })                  -- if, else
hi('Repeat', { fg = colors.keyword })                       -- for, while
hi('Label', { fg = colors.func })                           -- ::label::, label:
hi('Operator', { fg = colors.operator })                    -- +, -, =
hi('Keyword', { fg = colors.keyword })                      -- async, import
hi('Exception', { fg = colors.keyword })                    -- try, catch

hi('PreProc', { fg = colors.keyword })                      -- #ifdef, #endif
hi('Include', { fg = colors.keyword })                      -- #include
hi('Define', { fg = colors.keyword })                       -- Preprocessor #define
hi('Macro', { fg = colors.keyword })                        -- Same as Define

hi('Type', { fg = colors.types })                           -- int, float, char
hi('StorageClass', { fg = colors.types })                   -- static, register
hi('Structure', { fg = colors.keyword })                    -- struct, union, enum
hi('Typedef', { fg = colors.types })                        -- typedef

hi('Special', { fg = colors.special })                      -- ${var}
hi('SpecialChar', { fg = colors.special })                  -- \n, \t
hi('Tag', { fg = colors.types })
hi('Delimiter', { fg = colors.delimiter })                  -- () {}
hi('SpecialComment', { fg = colors.comment })
hi('Debug', { fg = colors.fg })

-- UI Elements
hi('LineNr', { fg = colors.linenumber })                                        -- Line number (:set number)
hi('CursorLineNr', { fg = colors.white, bold = true })                          -- Line number where the cursor is
hi('SignColumn', { fg = colors.fg, bg = colors.bg })                            -- Column next to the line number
hi('StatusLine', { fg = colors.black, bg = colors.statusline, bold = true })    -- Bar at the bottom of the UI
hi('StatusLineNC', { fg = colors.black, bg = colors.inactive })                 -- Status line when another window is active
hi('TabLine', { fg = colors.inactive, bg = colors.bg })                         -- Top UI bar of inactive tabs (:set showtabline=2)
hi('TabLineSel', { fg = colors.white, bg = colors.bg, bold = true })            -- Top UI bar of active tabs
hi('TabLineFill', { fg = colors.fg, bg = colors.bg })                           -- The remaning space and background
hi('VertSplit', { fg = colors.darkgrey })                                       -- Vertical split separator
hi('WinSeparator', { fg = colors.darkgrey })                                    -- Window separator (newer nvim)

-- Cursor and selection
hi('Cursor', { fg = colors.bg, bg = colors.fg })            -- Cursor in terminal mode
hi('CursorIM', { fg = colors.bg, bg = colors.fg })          -- Cursor in IME mode
hi('TermCursor', { fg = colors.bg, bg = colors.fg })        -- Terminal cursor
hi('TermCursorNC', { fg = colors.bg, bg = colors.grey })    -- Terminal cursor (non-focused)

-- Visual and selection
hi('Visual', { bg = colors.grey })                              -- Visual selection
hi('VisualNOS', { bg = colors.grey })                           -- Visual selection (not owning selection)
hi('Search', { fg = colors.black, bg = colors.highlight })      -- Search highlight (/search)
hi('IncSearch', { fg = colors.black, bg = colors.highlight })   -- Search highlight (while typing)
hi('CurSearch', { fg = colors.black, bg = colors.highlight })   -- Current search result
hi('Substitute', { fg = colors.black, bg = colors.highlight })  -- :substitute replacement text
hi('CursorLine', { bg = colors.subtlehl })                      -- Line of the cursor (:set cursorline)
hi('CursorColumn', { bg = colors.subtlehl })                    -- Column of the cursor (:set cursorcolumn)
hi('ColorColumn', { bg = colors.subtlehl })                     -- Column marker (:set colorcolumn)
hi('QuickFixLine', { bg = colors.subtlehl })                    -- Current line in quickfix window

-- Popup menu
hi('Pmenu', { fg = colors.fg, bg = colors.subtlehl })       -- Any popup menus
hi('PmenuSel', { fg = colors.fg, bg = colors.darkgrey })    -- The selected element in the popup
hi('PmenuSbar', { bg = colors.darkgrey })                   -- The scroll bar background for the popup
hi('PmenuThumb', { bg = colors.white })                     -- The scroll bar for the popup

-- Messages and errors
hi('ErrorMsg', { fg = colors.fg, bg = colors.errorred })    -- Error message
hi('WarningMsg', { fg = colors.warningred })                -- Warning message
hi('MoreMsg', { fg = colors.types, bold = true })           -- Normal messages (:echo)
hi('ModeMsg', { fg = colors.fg, bold = true })              -- Mode text: -- INSERT --

-- Diff colors (Vimdiff: nvim -d file1 file2)
hi('DiffAdd', { fg = colors.green })                        -- Vimdiff: lines that are added
hi('DiffChange', { fg = colors.grey })                      -- Vimdiff: lines that are changed
hi('DiffDelete', { fg = colors.red })                       -- Vimdiff: lines that are removed (dashed line)
hi('DiffText', { bg = colors.greyblue })                    -- Vimdiff: changed text inside a changed line

-- Folding
hi('Folded', { fg = colors.fg, bg = colors.darkgrey })      -- +-- Folded line
hi('FoldColumn', { fg = colors.grey, bg = colors.bg })      -- + Column of the fold

-- Spelling (:set spell)
hi('SpellBad', { undercurl = true, sp = colors.errorred })  -- Words spellt wrong
hi('SpellCap', { undercurl = true, sp = colors.types })     -- Words in all caps
hi('SpellLocal', { undercurl = true, sp = colors.keyword }) -- Local spelling color/colour
hi('SpellRare', { undercurl = true, sp = colors.number })   -- Rare spellings (antidisestablishmentarianism)

-- Floating windows
hi('FloatBorder', { fg = colors.grey, bg = colors.bg })     -- Floating window border
hi('FloatTitle', { fg = colors.func, bg = colors.bg })      -- Floating window title

-- Misc
hi('Directory', { fg = colors.cyan })                       -- Directory color (:Ex)
hi('Title', { fg = colors.grey, bold = true })              -- Titles (Top of :help)
hi('NonText', { fg = colors.darkgrey })                     -- Placeholder symbols (~ at end of file)
hi('EndOfBuffer', { fg = colors.darkgrey })                 -- ~ lines at end of buffer
hi('SpecialKey', { fg = colors.darkgrey })                  -- Special character (Trailing spaces with :set list)
hi('Whitespace', { fg = colors.darkgrey })                  -- Whitespace characters (:set list)
hi('MatchParen', { bg = colors.darkgrey, bold = true })     -- The matching {} when you hover over one
hi('Conceal', { fg = colors.grey })                         -- Concealed text
hi('Todo', { fg = colors.bg, bg = colors.highlight, bold = true })  -- TODO, FIXME

-- LSP (Semantic tokens)
hi('@lsp.type.class',         { fg = colors.class })        -- class Foo
hi('@lsp.type.enum',          { fg = colors.class })        -- enum Foo
hi('@lsp.type.interface',     { fg = colors.class })        -- interface Foo
hi('@lsp.type.struct',        { fg = colors.class })        -- struct Foo
hi('@lsp.type.type',          { fg = colors.class })        -- generic or typedef-like constructs
hi('@lsp.type.typeParameter', { fg = colors.class })        -- <T>, <U> in templates

hi('@lsp.type.function',      { fg = colors.func })         -- function foo()
hi('@lsp.type.method',        { fg = colors.func })         -- class method foo()
hi('@lsp.type.property',      { fg = colors.fg })           -- object.property
hi('@lsp.type.variable',      { fg = colors.fg })           -- let x = ...

hi('@lsp.type.parameter',     { fg = colors.fg })           -- function(param)
hi('@lsp.type.keyword',       { fg = colors.keyword })      -- if, else, for, etc.
hi('@lsp.type.namespace',     { fg = colors.class })        -- namespace MyApp
hi('@lsp.type.enumMember',    { fg = colors.enum })         -- Enum.Value
hi('@lsp.type.decorator',     { fg = colors.darkgrey })      -- @decorator
hi('@lsp.type.event',         { fg = colors.special })      -- UI events or similar
hi('@lsp.type.operator',      { fg = colors.operator })     -- +, -, *, /
hi('@lsp.type.comment',       { fg = colors.comment })      -- Semantic comments, fallback

-- LSP diagnostics (virtual text and signs)
hi('DiagnosticError',             { fg = colors.errorred })     -- Error in code
hi('DiagnosticWarn',              { fg = colors.warningred })   -- Warning in code
hi('DiagnosticInfo',              { fg = colors.types })        -- Informational hint
hi('DiagnosticHint',              { fg = colors.hintblue })     -- Hint or suggestion

-- LSP diagnostics in virtual text (inline errors)
hi('DiagnosticVirtualTextError',  { fg = colors.errorred })     -- Inline error
hi('DiagnosticVirtualTextWarn',   { fg = colors.warningred })   -- Inline warning
hi('DiagnosticVirtualTextInfo',   { fg = colors.types })        -- Inline info
hi('DiagnosticVirtualTextHint',   { fg = colors.hintblue })     -- Inline hint

-- LSP diagnostics underlines (with undercurl)
hi('DiagnosticUnderlineError',    { undercurl = true, sp = colors.errorred })   -- Error underline
hi('DiagnosticUnderlineWarn',     { undercurl = true, sp = colors.warningred }) -- Warning underline
hi('DiagnosticUnderlineInfo',     { undercurl = true, sp = colors.types })      -- Info underline
hi('DiagnosticUnderlineHint',     { undercurl = true, sp = colors.hintblue })   -- Hint underline

-- LSP diagnostics in the sign column (icons or symbols)
hi('DiagnosticSignError',         { fg = colors.errorred })     -- Sign: error
hi('DiagnosticSignWarn',          { fg = colors.warningred })   -- Sign: warning
hi('DiagnosticSignInfo',          { fg = colors.types })        -- Sign: info
hi('DiagnosticSignHint',          { fg = colors.hintblue })     -- Sign: hint

-- LSP inlay hints (parameter types, names, etc.)
hi('LspInlayHint', { fg = colors.grey, bg = colors.bg, italic = true }) -- Small inline type/name hints

-- LSP references (highlight when hovering symbol or using <Ctrl-]>)
hi('LspReferenceText',  { bg = colors.subtlehl })           -- Reference to symbol (default)
hi('LspReferenceRead',  { bg = colors.subtlehl })           -- Read reference
hi('LspReferenceWrite', { bg = colors.subtlehl })           -- Write reference

-- LSP CodeLens (extra info like # of references, test links, etc.)
hi('LspCodeLens',           { fg = colors.comment, italic = true }) -- Dimmed virtual text above functions
hi('LspCodeLensSeparator',  { fg = colors.darkgrey })               -- Separator between CodeLens items

-- Highlight of current parameter in signature help (e.g. when typing func(arg1,|)
hi('LspSignatureActiveParameter', { fg = colors.highlight, bold = true })   -- Highlight current param in call
