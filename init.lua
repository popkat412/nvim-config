-- {{{ PLUGINS (using neovim's builtin package manager)
vim.pack.add({
    -- 'basic' plugins
    "https://github.com/tpope/vim-surround",

    -- git
    "https://github.com/lewis6991/gitsigns.nvim",

    -- treesitter
    "https://github.com/nvim-treesitter/nvim-treesitter",

    -- lsp related
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",

    "https://github.com/stevearc/conform.nvim", -- handles format on save
    "https://github.com/b0o/schemastore.nvim", -- json schemastore for json ls

    -- completion
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },
    -- picker, file tree
    "https://github.com/folke/snacks.nvim",

    -- small plugins
    "https://github.com/NMAC427/guess-indent.nvim",
    "https://github.com/mrjones2014/smart-splits.nvim",
})
-- }}}

-- {{{ BASIC OPTIONS
vim.o.colorcolumn = "80" -- Highlight column 80
vim.o.updatetime = 500 -- When there is no user input for x ms, trigger the CursorHold autocmd
vim.o.signcolumn = "yes:1" -- Always show sign column
vim.o.termguicolors = true -- Enable true colors
vim.o.ignorecase = true -- Ignore case in search
vim.o.swapfile = false -- Disable swap files
vim.o.autoindent = true -- Enable auto indentation
vim.o.smartindent = true
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.tabstop = 4 -- Number of spaces for a tab
vim.o.softtabstop = 4 -- Number of spaces for a tab when editing
vim.o.shiftwidth = 4 -- Number of spaces for autoindent
vim.o.shiftround = true -- Round indent to multiple of shiftwidth
vim.o.listchars = "tab: ,multispace:|   " -- Characters to show for tabs, spaces
vim.o.list = true -- Show whitespace characters
vim.o.number = true -- Show line numbers
vim.o.relativenumber = true -- Show relative line numbers
vim.o.numberwidth = 2 -- Width of the line number column
vim.o.wrap = false -- Disable line wrapping
vim.o.cursorline = true -- Highlight the current line
vim.o.scrolloff = 8 -- Keep 8 lines above and below the cursor
vim.o.inccommand = "nosplit" -- Shows the effects of a command incrementally in the buffer
vim.o.undofile = true -- Enable persistent undo
vim.o.hlsearch = false -- Disable highlighting of search results
vim.o.splitright = true -- Open vsplits on the right instead of the left

vim.opt.foldmethod = "marker" -- use {{{ }}} markers
vim.opt.foldmarker = "{{{,}}}" -- default, explicit for clarity
vim.opt.foldlevelstart = 99

-- vim.o.completeopt = "menuone,popup,noinsert" -- Options for completion menu

vim.cmd.filetype("plugin indent on") -- Enable filetype detection, plugins, and indentation
-- }}}

-- {{{ COLORSCHEMES
-- packages
vim.pack.add({
    "https://github.com/tetzng/random-colorscheme.nvim",

    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
    "https://github.com/sainnhe/everforest",
    "https://github.com/sainnhe/sonokai",
    "https://github.com/shaunsingh/nord.nvim",
})
-- setup colorschemes
vim.g.everforest_background = "medium"
vim.g.sonokai_style = "atlantis"
-- pick a random one
require("random-colorscheme").setup({
    -- colorschemes = { "catppuccin-frappe", "everforest", "sonokai", "nord" },
    colorschemes = { "sonokai" },
})

-- }}}

-- {{{ KEYMAPS
-- note: lsp keymaps are in plugins/lsp.lua

vim.g.mapleader = " "

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "JK", "<Esc>")

vim.keymap.set("n", "<Leader>/", "gcc", { remap = true, desc = "Comment line" })
vim.keymap.set("v", "<Leader>/", "gc", { remap = true, desc = "Comment selection" })

vim.keymap.set("v", "<leader>y", [["+y]]) -- Yank into system clipboard
vim.keymap.set("v", "<leader>p", [["+p]]) -- Paste from system clipboard
vim.keymap.set("v", "<Leader>P", '"_dP') -- Paste without overwriting the default register

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "jk", "<C-\\><C-n>")

vim.keymap.set("n", "<leader>cc", function()
    require("random-colorscheme").set()
end, { desc = "Set Random Colorscheme" })

-- }}}

-- {{{ AUTOCMDS
vim.api.nvim_create_augroup("vimrc", { clear = true })

-- Don't automatically continue comments
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*",
    group = "vimrc",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})
-- }}}

-- {{{ PLUGIN CONFIG
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.blink")
require("plugins.snacks")
require("plugins.smart-splits")

-- small plugins
require("guess-indent").setup({})
-- }}}
