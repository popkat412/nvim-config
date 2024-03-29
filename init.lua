local map = require("config.utils").map
local au = require "au"

--[ Must Haves ]-- {{{
map { "i", "jk", "<Esc>", { noremap = true } }
map { "x", "p", "pgvy", { noremap = true } }

vim.o.syntax = "on"
vim.g.mapleader = " "
--}}}

--[ Colors ]-- {{{
-- {{{ old nightfox
-- require("nightfox").setup {
--     options = {
--         transparent = true,
--         styles = {
--             comments = "italic",
--             keywords = "italic",
--         },
--     },
--     palettes = {
--         all = {
--             bg_sidebar = "NONE",
--             bg = "NONE",
--         },
--     },
--     groups = {
--         DiagnosticVirtualTextError = { bg = "NONE" },
--         DiagnosticVirtualTextWarning = { bg = "NONE", fg = "#d08770" },
--         DiagnosticVirtualTextWarn = { bg = "NONE", fg = "#d08770" },
--         DiagnosticVirtualTextInformation = { bg = "NONE" },
--         DiagnosticVirtualTextInfo = { bg = "NONE" },
--         DiagnosticVirtualTextHint = { bg = "NONE", fg = "#88c0d0" },
--         LspDiagnosticsVirtualTextError = { bg = "NONE" },
--         LspDiagnosticsVirtualTextWarning = { bg = "NONE", fg = "#d08770" },
--         LspDiagnosticsVirtualTextWarn = { bg = "NONE", fg = "#d08770" },
--         LspDiagnosticsVirtualTextInformation = { bg = "NONE" },
--         LspDiagnosticsVirtualTextInfo = { bg = "NONE" },
--         LspDiagnosticsVirtualTextHint = { bg = "NONE", fg = "#88c0d0" },

--         Todo = { fg = "black" },

--         GitSignsAdd = { fg = "#a3be8c" },
--         GitSignsChange = { fg = "#b48ead" },
--         GitSignsDelete = { fg = "#bf616a" },
--     },
-- }

-- vim.cmd "colorscheme nordfox"
-- }}}

-- {{{ palenight
-- vim.g.palenight_terminal_italics = 1
-- vim.cmd [[
-- colorscheme palenight
-- ]]
-- }}}

vim.o.background = "dark"
vim.o.termguicolors = true

vim.g.everforest_enable_italic = true
vim.g.everforest_diagnostic_virtual_text = "colored"
vim.g.everforest_better_performance = true
vim.g.everforest_transparent_background = true
vim.cmd [[
colorscheme everforest
]]

-- require("transparent").setup {
--     enable = true,
--     extra_groups = {
--         "NormalFloat",
--     },
-- }
--}}}

--[ Options ]-- {{{
vim.cmd "filetype plugin on"

vim.o.laststatus = 3

vim.o.relativenumber = true

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.hidden = true
vim.o.scrolloff = 5
vim.o.mouse = "a"

vim.o.swapfile = false

vim.o.wrap = false

vim.o.ignorecase = true

vim.o.backup = false
vim.o.writebackup = false

vim.o.signcolumn = "yes"

vim.o.updatetime = 300

vim.o.hlsearch = false

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.foldmethod = "marker"

vim.o.undodir = "~/.vim/undo"

vim.o.list = true
vim.o.listchars = "tab:▸·"

vim.g.tex_flavor = "latex"
-- }}}

--[ Keymaps ]-- {{{
-- https://www.youtube.com/watch?v=hSHATqh8svM
-- keep cursor centered
map { "n", "n", "nzzzv" }
map { "n", "N", "Nzzzv" }
map { "n", "J", "mzJ`z" }
-- capital y to yank until end of line
map { "n", "Y", "y$" }
-- undo breakpoints
local breakpointLetters = { ",", ".", "!", "?" }
for _, letter in ipairs(breakpointLetters) do
    map { "i", letter, letter .. "<c-g>u" }
end
-- jumplist mutations
map { "n", "k", [[(v:count > 5 ? "m'" . v:count : "") . 'k' ]], { noremap = true, expr = true } }
map { "n", "j", [[(v:count > 5 ? "m'" . v:count : "") . 'j' ]], { noremap = true, expr = true } }
-- option+backspace to delete word
map { "i", "<M-BS>", "<C-w>", { noremap = false } }
map { "c", "<M-BS>", "<C-w>", { noremap = false } }
--select all
map { "n", "<leader><leader>", "ggVG" }
-- yank to system clipboard
map { "v", "<leader>y", [["+y]] }
-- paste from system clipboard
map { "n", "<leader>p", [["+p]] }
map { "v", "<leader>p", [["+p]] }
-- F10 to show highlight group
map {
    "n",
    "<F10>",
    [[:echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>]],
}

-- move lines (https://vim.fandom.com/wiki/Moving_lines_up_or_down#Mappings_to_move_lines)
map { "n", "∆", ":m .+1<CR>==" }
map { "n", "˚", ":m .-2<CR>==" }
map { "i", "∆", "<Esc>:m .+1<CR>==gi" }
map { "i", "˚", "<Esc>:m .-2<CR>==gi" }
map { "v", "∆", ":m '>+1<CR>gv=gv" }
map { "v", "˚", ":m '<-2<CR>gv=gv" }

-- switch between splits
vim.g.kitty_navigator_no_mappings = 1
map { "n", "<C-left>", ":KittyNavigateLeft<CR>", { noremap = true, silent = true } }
map { "n", "<C-down>", ":KittyNavigateDown<CR>", { noremap = true, silent = true } }
map { "n", "<C-up>", ":KittyNavigateUp<CR>", { noremap = true, silent = true } }
map { "n", "<C-right>", ":KittyNavigateRight<CR>", { noremap = true, silent = true } }
-- making new splits
map { "n", "<S-Left>", "<C-w>v<C-w>h" }
map { "n", "<S-Down>", "<C-w>s" }
map { "n", "<S-Up>", "<C-w>s<C-w>k" }
map { "n", "<S-Right>", "<C-w>v" }
-- Copyright Tux 2020-2021. Do not reproduce without explicit permission.
-- All reproductions must bear this original unmodified copyright notice.
-- }}}

--[ Autocommands ]-- {{{
-- disable auto comment
au.group("disable_autocomment", function(grp)
    grp.FileType = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o"
end)

-- tab size
local function mk_tabsize_fn(tabsize)
    return function()
        vim.bo.tabstop = tabsize
        vim.bo.shiftwidth = tabsize
        vim.bo.softtabstop = tabsize
    end
end
local two_spaces_filetypes = {
    "haskell",
    "html",
    "css",
    "scss",
    "javascript",
    "markdown",
    "typescript",
    "typescriptreact",
    "javascriptreact",
    "dart",
    "vue",
    "json",
    "vim",
}
au.group("tab_size", function(grp)
    grp.FileType = {
        table.concat(two_spaces_filetypes, ","),
        mk_tabsize_fn(2),
    }
    grp.FileType = {
        "make",
        mk_tabsize_fn(8),
    }
end)
-- }}}

--[ Functions ]-- {{{
_G.load = function(file)
    require("plenary.reload").reload_module(file, true)
    return require(file)
end
-- }}}

--[ Plugins & Plugin config ]-- {{{
require "config"
-- }}}
