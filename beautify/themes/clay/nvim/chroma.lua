-- Chroma "clay" neovim color scheme.
-- Minimal self-contained 16-color theme derived from the Chroma ghostty
-- palette. Load with:  vim.cmd("colorscheme chroma-clay")
-- See beautify/README for wiring into LazyVim.
vim.cmd([[hi clear]])
vim.o.background = "dark"
vim.g.colors_name = "chroma-clay"

local bg     = "#241e1a"
local fg     = "#ede0d4"
local red    = "#d46a5a"
local green  = "#a3b88a"
local yellow = "#e0b97c"
local blue   = "#c2855a"
local mag    = "#b89ab3"
local cyan   = "#7ab8a0"
local white  = "#ede0d4"
local bright = "#665a50"
local selb   = "#ede0d4"
local selfg  = "#241e1a"

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
