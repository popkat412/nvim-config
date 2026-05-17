local snacks = require("snacks")

snacks.setup({
    explorer = {
        trash = true,
        replace_netrw = true,
    },

    picker = {
        -- fd is auto-detected and used over find when available.
        -- rg is auto-detected and used over grep when available.
        -- Nothing to configure for that — snacks just picks them up.

        -- Default layout: "telescope"-style split with preview on the right.
        -- Other built-ins: "ivy" (bottom panel), "vscode" (top), "vertical", "sidebar"
        layout = { preset = "telescope" },

        -- Show hidden files (dotfiles) in file pickers
        hidden = true,

        -- Respect .gitignore (set false to ignore it)
        ignored = false,

        sources = {
            files = {
                matcher = {
                    frecency = true,
                    history_bonus = true,
                    sort_empty = true,
                },
                sort = { fields = { "score:desc", "idx" } },
            },
        },

        win = {
            input = {
                keys = {
                    -- In the input box: move to list with Tab, close with Esc
                    ["<Esc>"] = { "close", mode = { "n", "i" } },
                    ["<C-j>"] = { "list_down", mode = { "i", "n" } },
                    ["<C-k>"] = { "list_up", mode = { "i", "n" } },
                    ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
                    ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
                },
            },
        },
    },
})

-- ─── Keymaps ──────────────────────────────────────────────────────────────────

local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
end

-- stylua: ignore start

-- Explorer
map("<leader>e", function() snacks.explorer.open() end, "Open explorer")

-- Files
map("<leader>ff", function() snacks.picker.files() end, "Find files")
map("<leader>fr", function() snacks.picker.recent() end, "Recent files")
map("<leader>fb", function() snacks.picker.buffers() end, "Open buffers")

-- Grep
map("<leader>fg", function() snacks.picker.grep() end, "Live grep")
map("<leader>fw", function() snacks.picker.grep_word() end, "Grep word under cursor")

-- Misc
map("<leader>fh", function() snacks.picker.help() end, "Help pages")
map("<leader>f:", function() snacks.picker.command_history() end, "Command history")
map("<leader>fd", function() snacks.picker.diagnostics() end, "Diagnostics")
map("<leader>fu", function() snacks.picker.undo() end, "Undo history")


-- Resume last picker
map("<leader>fp", function() snacks.picker.resume() end, "Resume last picker")

-- Colorschemes
map("<leader>uC", function() snacks.picker.colorschemes() end, "Colroschemes")

-- stylua: ignore end
