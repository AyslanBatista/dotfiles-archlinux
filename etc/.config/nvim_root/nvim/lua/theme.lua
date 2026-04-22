-- Palette baseada no tokyonight-moon
local c = {
    bg        = "#222436",
    bg_dark   = "#1e2030",
    bg_float  = "#1e2030",
    bg_popup  = "#1e2030",
    bg_sel    = "#2d3f76",
    bg_visual = "#2d3f76",

    fg        = "#c8d3f5",
    fg_dark   = "#828bb8",
    fg_gutter = "#3b4261",

    blue      = "#82aaff",
    blue1     = "#65bcff",
    cyan      = "#86e1fc",
    green     = "#c3e88d",
    green1    = "#4fd6be",
    magenta   = "#c099ff",
    orange    = "#ff966c",
    red       = "#ff757f",
    red1      = "#c53b53",
    teal      = "#4fd6be",
    yellow    = "#ffc777",
    purple    = "#fca7ea",

    comment   = "#636da6",
    border    = "#589ed7",
}

-- Reseta highlights existentes
vim.cmd("highlight clear")
vim.cmd("syntax reset")
vim.g.colors_name = "moon"

local hl = vim.api.nvim_set_hl

-- ============================================================
-- BASE
-- ============================================================
hl(0, "Normal",         { fg = c.fg,       bg = c.bg })
hl(0, "NormalFloat",    { fg = c.fg,       bg = c.bg_float })
hl(0, "NormalNC",       { fg = c.fg,       bg = c.bg_dark })
hl(0, "ColorColumn",    { bg = c.bg_dark })
hl(0, "Conceal",        { fg = c.fg_dark })
hl(0, "CursorLine",     { bg = "#2a2d3d" })
hl(0, "CursorLineNr",   { fg = c.yellow,   bold = true })
hl(0, "LineNr",         { fg = c.fg_gutter })
hl(0, "SignColumn",     { fg = c.fg_gutter, bg = c.bg })
hl(0, "VertSplit",      { fg = c.fg_gutter })
hl(0, "WinSeparator",   { fg = c.fg_gutter })
hl(0, "Folded",         { fg = c.comment,  bg = c.bg_dark })
hl(0, "FoldColumn",     { fg = c.comment,  bg = c.bg })
hl(0, "MatchParen",     { fg = c.orange,   bold = true, underline = true })
hl(0, "NonText",        { fg = c.fg_gutter })
hl(0, "Whitespace",     { fg = c.fg_gutter })
hl(0, "SpecialKey",     { fg = c.fg_gutter })

-- ============================================================
-- BUSCA E SELEÇÃO
-- ============================================================
hl(0, "Search",         { fg = c.bg,    bg = c.yellow })
hl(0, "IncSearch",      { fg = c.bg,    bg = c.orange })
hl(0, "Visual",         { bg = c.bg_visual })
hl(0, "VisualNOS",      { bg = c.bg_visual })

-- ============================================================
-- POPUP MENU (completion nativo)
-- ============================================================
hl(0, "Pmenu",          { fg = c.fg,      bg = c.bg_popup })
hl(0, "PmenuSel",       { fg = c.fg,      bg = c.bg_sel, bold = true })
hl(0, "PmenuSbar",      { bg = c.bg_popup })
hl(0, "PmenuThumb",     { bg = c.fg_dark })

-- ============================================================
-- MENSAGENS E STATUS
-- ============================================================
hl(0, "ErrorMsg",       { fg = c.red })
hl(0, "WarningMsg",     { fg = c.yellow })
hl(0, "ModeMsg",        { fg = c.fg,      bold = true })
hl(0, "Question",       { fg = c.blue })
hl(0, "Title",          { fg = c.blue,    bold = true })

-- ============================================================
-- SYNTAX HIGHLIGHTING
-- ============================================================
hl(0, "Comment",        { fg = c.comment, italic = true })
hl(0, "Constant",       { fg = c.orange })
hl(0, "String",         { fg = c.green })
hl(0, "Character",      { fg = c.green })
hl(0, "Number",         { fg = c.orange })
hl(0, "Boolean",        { fg = c.orange })
hl(0, "Float",          { fg = c.orange })
hl(0, "Identifier",     { fg = c.magenta })
hl(0, "Function",       { fg = c.blue })
hl(0, "Statement",      { fg = c.magenta })
hl(0, "Keyword",        { fg = c.cyan,    italic = true })
hl(0, "Conditional",    { fg = c.magenta, italic = true })
hl(0, "Repeat",         { fg = c.magenta, italic = true })
hl(0, "Label",          { fg = c.blue })
hl(0, "Operator",       { fg = c.blue1 })
hl(0, "Exception",      { fg = c.magenta })
hl(0, "PreProc",        { fg = c.cyan })
hl(0, "Include",        { fg = c.cyan })
hl(0, "Define",         { fg = c.magenta })
hl(0, "Macro",          { fg = c.cyan })
hl(0, "Type",           { fg = c.yellow })
hl(0, "StorageClass",   { fg = c.cyan })
hl(0, "Structure",      { fg = c.yellow })
hl(0, "Typedef",        { fg = c.yellow })
hl(0, "Special",        { fg = c.blue1 })
hl(0, "Delimiter",      { fg = c.blue1 })
hl(0, "Underlined",     { underline = true })
hl(0, "Error",          { fg = c.red })
hl(0, "Todo",           { fg = c.bg,      bg = c.yellow, bold = true })

-- ============================================================
-- LSP DIAGNOSTICS
-- ============================================================
hl(0, "DiagnosticError",           { fg = c.red })
hl(0, "DiagnosticWarn",            { fg = c.yellow })
hl(0, "DiagnosticInfo",            { fg = c.blue1 })
hl(0, "DiagnosticHint",            { fg = c.teal })
hl(0, "DiagnosticUnderlineError",  { undercurl = true, sp = c.red })
hl(0, "DiagnosticUnderlineWarn",   { undercurl = true, sp = c.yellow })
hl(0, "DiagnosticUnderlineInfo",   { undercurl = true, sp = c.blue1 })
hl(0, "DiagnosticUnderlineHint",   { undercurl = true, sp = c.teal })

-- ============================================================
-- TREESITTER (grupos @)
-- ============================================================
hl(0, "@comment",               { link = "Comment" })
hl(0, "@string",                { link = "String" })
hl(0, "@number",                { link = "Number" })
hl(0, "@float",                 { link = "Float" })
hl(0, "@boolean",               { link = "Boolean" })
hl(0, "@keyword",               { fg = c.magenta, italic = true })
hl(0, "@keyword.return",        { fg = c.magenta, italic = true })
hl(0, "@keyword.function",      { fg = c.cyan,    italic = true })
hl(0, "@function",              { fg = c.blue })
hl(0, "@function.call",         { fg = c.blue })
hl(0, "@function.builtin",      { fg = c.cyan })
hl(0, "@method",                { fg = c.blue })
hl(0, "@method.call",           { fg = c.blue })
hl(0, "@parameter",             { fg = c.yellow })
hl(0, "@variable",              { fg = c.fg })
hl(0, "@variable.builtin",      { fg = c.red })
hl(0, "@field",                 { fg = c.green1 })
hl(0, "@property",              { fg = c.green1 })
hl(0, "@type",                  { fg = c.yellow })
hl(0, "@type.builtin",          { fg = c.yellow, italic = true })
hl(0, "@constructor",           { fg = c.magenta })
hl(0, "@operator",              { fg = c.blue1 })
hl(0, "@punctuation.bracket",   { fg = c.fg_dark })
hl(0, "@punctuation.delimiter", { fg = c.blue1 })
hl(0, "@tag",                   { fg = c.magenta })
hl(0, "@tag.attribute",         { fg = c.yellow })
hl(0, "@tag.delimiter",         { fg = c.blue1 })
hl(0, "@namespace",             { fg = c.fg_dark, italic = true })
hl(0, "@constant",              { fg = c.orange })
hl(0, "@constant.builtin",      { fg = c.orange, bold = true })
hl(0, "@include",               { fg = c.cyan })
hl(0, "@exception",             { fg = c.magenta })
hl(0, "@conditional",           { fg = c.magenta, italic = true })
hl(0, "@repeat",                { fg = c.magenta, italic = true })
hl(0, "@label",                 { fg = c.blue })
hl(0, "@string.escape",         { fg = c.cyan })
hl(0, "@string.special",        { fg = c.cyan })
