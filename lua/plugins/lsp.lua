-- mason, mason-lspconfig to auto install tooling
require("mason").setup()

require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",

        -- web dev bullshit
        "ts_ls",
        "astro",
        "svelte",
        "vue_ls",
        "html",
        "jsonls",
        "emmet_ls",
        "cssls",
        "tailwindcss",
        "biome", -- linter + formatter, replces prettier & eslint
    },
})
-- no need to vim.lsp.enable() since mason-lspconfig does it automatically

-- {{{ GLOBAL LSP SETTINGS
vim.diagnostic.config({
    virtual_text = true,

    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
        underline = true,
        update_in_insert = false, -- don't flicker diagnostics while typing
        severity_sort = true,
        float = {
            source = true, -- show which server the diagnostic is from
            header = "",
            prefix = "",
        },
    },
})

-- Float diagnostic on hover
vim.api.nvim_create_autocmd("CursorHold", {
    group = "vimrc",
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})

-- Keymaps
vim.api.nvim_create_autocmd("LspAttach", {
    group = "vimrc",
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end
        local buf = args.buf
        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
        end

        -- ── Navigation ───────────────────────────────────────────────────────────
        -- Note: gd is a default in 0.12 but we redefine explicitly for clarity.
        -- 'tagfunc' already covers <C-]> / :tjump, so these are just conveniece maps.
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
        map("n", "gr", vim.lsp.buf.references, "References")

        -- ── Hover & signature ─────────────────────────────────────────────────────
        -- K is already mapped by Neovim 0.12 defaults, but we add a second binding
        -- and also wire up signature help.
        map("n", "K", vim.lsp.buf.hover, "Hover docs")
        map("n", "<leader>k", vim.lsp.buf.hover, "Hover docs (alt)")
        map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
        map("n", "<leader>K", vim.lsp.buf.signature_help, "Signature help (normal)")

        -- ── Code actions & refactoring ────────────────────────────────────────────
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")

        -- ── Diagnostics ───────────────────────────────────────────────────────────
        map("n", "<leader>d", vim.diagnostic.open_float, "Show diagnostics float")
        map("n", "[d", function()
            vim.diagnostic.jump({ count = 1, float = true })
        end, "Prev diagnostic")
        map("n", "]d", function()
            vim.diagnostic.jump({ count = -1, float = true })
        end, "Next diagnostic")
        map("n", "[e", function()
            vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
        end, "Prev error")
        map("n", "]e", function()
            vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR })
        end, "Next error")
        map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics → loclist")
        map("n", "<leader>Q", vim.diagnostic.setqflist, "Diagnostics → quickfix")

        -- ── Workspace ─────────────────────────────────────────────────────────────
        -- map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
        -- map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
        -- map("n", "<leader>wl", function()
        -- 	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        -- end, "List workspace folders")

        -- ── Inlay hints (0.10+) ───────────────────────────────────────────────────
        -- (parameter names, return types, etc.)
        if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(false, { bufnr = buf })
            map("n", "<leader>ih", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "Toggle inlay hints")
        end

        -- ── Document highlight on cursor rest ─────────────────────────────────────
        -- Highlight all occurrences of the symbol under the cursor.
        if client:supports_method("textDocument/documentHighlight") then
            local hl_group = vim.api.nvim_create_augroup("my_lsp_highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = buf,
                group = hl_group,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd("CursorMoved", {
                buffer = buf,
                group = hl_group,
                callback = vim.lsp.buf.clear_references,
            })
        end

        -- ── Auto-format on save using conform.nvim ───────────────────────────────────────────────────

        -- ── Manual format keymap (always available) ───────────────────────────────
        map({ "n", "v" }, "<leader>lf", function()
            require("conform").format({ bufnr = args.buf })
        end, "Format buffer/range")

        -- ── Native completion (built-in, no plugin needed) ────────────────────────
        -- if client:supports_method("textDocument/completion") then
        -- 	vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
        -- end
    end,
})
-- }}}

-- {{{ AUTOFORMAT ON SAVE (using conform.js)
require("conform").setup({
    formatters_by_ft = {
        -- explicit external formatters
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        css = { "biome" },
        vue = { "biome" },
        svelte = { "biome" },
        astro = { "prettier" },
        -- lua, rust, go, etc. have no entry here — they fall through to LSP
    },
    format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = true, -- this is the key: falls back to vim.lsp.buf.format() for anything not listed above
    },
})
-- }}}

-- {{{ WEB LSP SETTINGS

-- ─── Vue: wire ts_ls to load the @vue/typescript-plugin ────────────────────
-- vue_ls handles CSS/HTML in .vue files; ts_ls handles the TypeScript parts.
-- They need to know about each other.

local vue_plugin_path = vim.fn.expand("$MASON/packages/vue-language-server") .. "/node_modules/@vue/language-server"

vim.lsp.config("ts_ls", {
    init_options = {
        plugins = {
            {
                name = "@vue/typescript-plugin",
                location = vue_plugin_path,
                languages = { "vue" },
            },
        },
    },
    -- Add "vue" so ts_ls also attaches to .vue files
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "vue",
    },
})

vim.lsp.config("eslint", {
    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "astro", -- not included by default
    },
    root_dir = function(bufnr, cb)
        local root = vim.fs.root(bufnr, {
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.json",
            "eslint.config.js",
            "eslint.config.mjs",
            "eslint.config.cjs",
            "eslint.config.ts",
            ".git",
        })
        if root then
            cb(root)
        end
    end,
    workspace_required = false,
    settings = {
        format = false,
    },
})

-- ─── jsonls: enable JSON schema completions (package.json, tsconfig, etc.) ────
vim.lsp.config("jsonls", {
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(), -- needs schemastore plugin, see below
            validate = { enable = true },
        },
    },
})
-- }}}
