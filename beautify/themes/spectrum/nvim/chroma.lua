-- Chroma "spectrum" neovim color scheme.
-- Minimal self-contained 16-color theme derived from the Chroma ghostty
-- palette. Load with:  vim.cmd("colorscheme chroma-spectrum")
-- See beautify/README for wiring into LazyVim.
vim.cmd([[hi clear]])
vim.o.background = "dark"
vim.g.colors_name = "chroma-spectrum"

local bg     = "#2d2a2e"
local fg     = "#fcfcfa"
local red    = "#ff6188"
local green  = "#a9dc76"
local yellow = "#ffd866"
local blue   = "#fc9867"
local mag    = "#ab9df2"
local cyan   = "#78dce8"
local white  = "#fcfcfa"
local bright = "#727072"
local selb   = "#fcfcfa"
local selfg  = "#2d2a2e"

local s = vim.api.nvim_set_hl
s(0, "Normal",          { fg = fg, bg = bg })
s(0, "NormalFloat",     { fg = fg, bg = bg })
s(0, "EndOfBuffer",     { fg = bg })
s(0, "CursorLine",      { bg = bright })
s(0, "CursorLineNr",    { fg = yellow })
s(0, "LineNr",          { fg = bright })
s(0, "Comment",         { fg = bright, italic = true })
s(0, "String",          { fg = green })
s(0, "Number",          { fg = yellow })
s(0, "Boolean",         { fg = yellow })
s(0, "Float",           { fg = yellow })
s(0, "Character",       { fg = green })
s(0, "Function",        { fg = blue })
s(0, "Keyword",         { fg = mag })
s(0, "Statement",       { fg = mag })
s(0, "Conditional",     { fg = mag })
s(0, "Repeat",          { fg = mag })
s(0, "Operator",        { fg = cyan })
s(0, "Type",            { fg = yellow })
s(0, "Identifier",      { fg = fg })
s(0, "Constant",        { fg = mag })
s(0, "PreProc",         { fg = cyan })
s(0, "Define",          { fg = cyan })
s(0, "Special",         { fg = cyan })
s(0, "Delimiter",       { fg = fg })
s(0, "Tag",             { fg = cyan })
s(0, "Underlined",      { fg = blue, underline = true })
s(0, "Directory",       { fg = blue })
s(0, "Error",           { fg = bg, bg = red, bold = true })
s(0, "Todo",            { fg = mag, bold = true })
s(0, "Search",          { fg = bg, bg = cyan })
s(0, "IncSearch",       { fg = bg, bg = yellow })
s(0, "Visual",          { fg = selfg, bg = selb })
s(0, "VisualNOS",       { fg = fg, bg = selb })
s(0, "MatchParen",      { fg = mag, bold = true })
s(0, "Pmenu",           { fg = fg, bg = bright })
s(0, "PmenuSel",        { fg = bg, bg = blue })
s(0, "StatusLine",      { fg = bg, bg = blue })
s(0, "StatusLineNC",    { fg = fg, bg = bright })
s(0, "Tab",             { fg = bg, bg = blue })
s(0, "TabLineSel",      { fg = bg, bg = blue })
s(0, "TabLineFill",     { fg = fg, bg = bright })
s(0, "Title",           { fg = mag, bold = true })
s(0, "DiagnosticError", { fg = red })
s(0, "DiagnosticWarn",  { fg = yellow })
s(0, "DiagnosticInfo",  { fg = cyan })
s(0, "DiagnosticHint",  { fg = mag })
