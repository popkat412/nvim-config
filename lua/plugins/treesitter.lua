local ts = require("nvim-treesitter")

-- Ensure installed
local ensure_installed = {
    -- Shell & system
    "bash",
    -- Web
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "json",
    "json5",
    "yaml",
    "toml",
    "svelte",
    "vue",
    "svelte",
    -- Systems / backend
    "c",
    "cpp",
    "rust",
    "go",
    "python",
    "lua",
    -- Functional
    "haskell",
    -- DevOps / config
    "dockerfile",
    "terraform",
    "hcl",
    "nix",
    -- Docs / markup
    "markdown",
    "markdown_inline",
    "rst",
    "latex",
    -- Git
    "git_config",
    "gitcommit",
    "gitignore",
    "git_rebase",
    -- Neovim-specific
    "vim",
    "vimdoc",
    "query",
    "luadoc",
    -- Data
    "sql",
    -- Misc
    "regex",
    "comment",
}
for _, parser in ipairs(ensure_installed) do
    ts.install(parser)
end

-- Highlighting (provided natively in v0.12)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    group = "vimrc",
    callback = function(args)
        -- Only start if a parser actually exists for this filetype
        pcall(vim.treesitter.start, args.buf)
    end,
})

-- Indentation (provided by nvim-treesitter plugin)
vim.api.nvim_create_autocmd("FileType", {
    -- Exclude filetypes with flaky TS indent queries
    pattern = "*",
    group = "vimrc",
    callback = function(args)
        local excluded = { python = true, yaml = true }
        local ft = vim.bo[args.buf].filetype
        if excluded[ft] then
            return
        end

        local ok = pcall(vim.treesitter.get_parser, args.buf)
        if not ok then
            return
        end

        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

-- -- Folding (fully native in v0.12)
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = "*",
--     group = "vimrc",
--     callback = function(args)
--         local ok = pcall(vim.treesitter.get_parser, args.buf)
--         if not ok then
--             return
--         end
--
--         -- Use window-local options scoped to this buffer (vim.wo[0][0] idiom)
--         vim.wo[0][0].foldmethod = "expr"
--         vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
--         vim.opt_local.foldtext = "v:lua.vim.treesitter.foldtext()"
--         vim.opt_local.foldenable = true
--         vim.opt_local.foldlevel = 99
--         vim.opt_local.foldlevelstart = 99
--         vim.opt_local.foldnestmax = 10
--     end,
-- })

-- Incremental selection
vim.keymap.set("n", "<CR>", "van", { remap = true, desc = "Start TS node selection" })
vim.keymap.set("x", "<CR>", "an", { remap = true, desc = "Expand TS node selection" })
vim.keymap.set("x", "<S-CR>", "in", { remap = true, desc = "Shrink TS node selection" })
