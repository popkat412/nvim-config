-- vim:foldmethod=marker

local nvim_lsp = require "lspconfig"
local au = require "au"

local M = {}

-- {{{ On attach
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
M.on_attach = function(_, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    --Enable completion triggered by <c-x><c-o>
    buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    local opts = { noremap = true, silent = true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
    buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    -- buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    -- buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    -- buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    -- buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    buf_set_keymap("n", "<space>ca", "<cmd>lua require('telescope.builtin').lsp_code_actions()<CR>", opts)
    buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    buf_set_keymap("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
    buf_set_keymap("n", "<space>[", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
    buf_set_keymap("n", "<space>]", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
    buf_set_keymap("n", "<space>qq", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
    buf_set_keymap("n", "<space>ff", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end
-- }}}

-- {{{ Default config

-- stylua: ignore start
nvim_lsp.util.default_config = vim.tbl_extend("force",
    nvim_lsp.util.default_config,
    {
        handlers = {
            ["textDocument/publishDiagnostics"] = vim.lsp.with(
                vim.lsp.diagnostic.on_publish_diagnostics, {
                    update_in_insert = true,
                    -- virtual_text = false,
                }
            ),
        },
    }
)
-- stylua: ignore end

-- show the diagnostics in a popup
-- vim.cmd [[
-- autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics({ focusable = false })
-- autocmd CursorHoldI * silent! lua vim.lsp.diagnostic.show_line_diagnostics({ focusable = false })
-- ]]
au.group("lspconfig", function(grp)
    grp.CursorHold = function()
        vim.lsp.diagnostic.show_line_diagnostics { focusable = false }
    end
    grp.CursorHoldI = "silent! vim.lsp.diagnostic.show_line_diagnostics { focusable = false }"
end)

-- }}}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- {{{ LSPs without special config
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "pyright", "hls", "clangd", "jsonls", "bashls", "elmls" }
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        capabilities = capabilities,
        on_attach = M.on_attach,
        flags = {
            debounce_text_changes = 150,
        },
    }
end
-- }}}

-- {{{ Web: html, typescript, javascript, vue, eslint

-- html
nvim_lsp.html.setup {
    capabilities = capabilities,
    on_attach = on_attach,
}

-- css/scss
nvim_lsp.cssls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
}

-- typescript
nvim_lsp.tsserver.setup {
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        on_attach(client)
    end,
    flags = {
        debounce_text_changes = 150,
    },
}

-- linter
local filetypes = {
    typescript = "eslint",
    typescriptreact = "eslint",
}
local linters = {
    eslint = {
        sourceName = "eslint",
        command = "eslint_d",
        rootPatterns = { ".eslintrc.js", "package.json" },
        debounce = 100,
        args = { "--stdin", "--stdin-filename", "%filepath", "--format", "json" },
        parseJson = {
            errorsRoot = "[0].messages",
            line = "line",
            column = "column",
            endLine = "endLine",
            endColumn = "endColumn",
            message = "${message} [${ruleId}]",
            security = "severity",
        },
        securities = { [2] = "error", [1] = "warning" },
    },
}
local formatters = {
    prettier = { command = "prettier", args = { "--stdin-filepath", "%filepath" } },
}
local formatFiletypes = {
    typescript = "prettier",
    typescriptreact = "prettier",
}
nvim_lsp.diagnosticls.setup {
    on_attach = on_attach,
    filetypes = vim.tbl_keys(filetypes),
    init_options = {
        filetypes = filetypes,
        linters = linters,
        formatters = formatters,
        formatFiletypes = formatFiletypes,
    },
}

-- vue
nvim_lsp.vuels.setup {
    -- https://github.com/ngtinsmith/dotfiles/blob/b78bf3115d746d037c814ce6767b4c6ba38021c5/.vimrc#L559
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = true
        on_attach(client)
    end,
    init_options = {
        config = {
            vetur = {
                completion = {
                    autoImport = true,
                    useScaffoldSnippets = true,
                },
                format = {
                    defaultFormatter = {
                        js = "prettier",
                        ts = "prettier",
                        css = "prettier",
                        html = "prettier",
                    },
                },
            },
        },
    },
    flags = {
        debounce_text_changes = 150,
    },
}
-- vue autoformat
au.group("VueFmt", function(grp)
    grp.BufWritePre = {
        "*.vue",
        function()
            vim.lsp.buf.formatting_sync(nil, 1000)
        end,
    }
end)
-- }}}

-- {{{ Lua
local system_name = "macOS"
local sumneko_root_path = "/Users/yunze/Documents/Coding/other-ppl/lua-language-server"
local sumneko_binary = sumneko_root_path .. "/bin/" .. system_name .. "/lua-language-server"

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require("lspconfig").sumneko_lua.setup {
    cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" },
    on_attach = on_attach,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
                -- Setup your lua path
                path = runtime_path,
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

-- }}}

-- {{{ Icons
local lsp_signs = {
    LspDiagnosticsSignHint = {
        text = "■",
        texthl = "LspDiagnosticsSignHint",
    },
    LspDiagnosticsSignInformation = {
        text = "■",
        texthl = "LspDiagnosticsSignInformation",
    },
    LspDiagnosticsSignWarning = {
        text = "▲",
        texthl = "LspDiagnosticsSignWarning",
    },
    LspDiagnosticsSignError = {
        text = "●",
        texthl = "LspDiagnosticsSignError",
    },
}

for hl_group, config in pairs(lsp_signs) do
    vim.fn.sign_define(hl_group, config)
end

-- }}}

return M
