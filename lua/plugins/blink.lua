require("blink.cmp").setup({
    -- ── Fuzzy matching ─────────────────────────────────────────────────────────
    -- "prefer_rust_with_warning" uses the fast Rust binary if available,
    -- warns if it isn't (so you notice), then falls back to the Lua impl.
    -- Use "lua" if you don't want any binary downloads at all.
    fuzzy = {
        implementation = "prefer_rust_with_warning",
        -- Boost exact-prefix matches above fuzzy ones
        sorts = { "exact", "score", "sort_text" },
    },

    -- ── Keymaps ────────────────────────────────────────────────────────────────
    keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },

        ["<Tab>"] = {
            function(cmp)
                if cmp.snippet_active() then
                    return cmp.snippet_forward()
                else
                    return cmp.select_next()
                end
            end,
            "fallback",
        },
        ["<S-Tab>"] = {
            function(cmp)
                if cmp.snippet_active() then
                    return cmp.snippet_backward()
                else
                    return cmp.select_prev()
                end
            end,
            "fallback",
        },

        ["<Enter>"] = { "accept", "fallback" },

        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-j>"] = { "select_prev", "fallback_to_mappings" },
        ["<C-k>"] = { "select_next", "fallback_to_mappings" },

        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
    },

    -- ── Completion behaviour ───────────────────────────────────────────────────
    completion = {
        -- Trigger: show menu automatically as you type
        trigger = {
            show_on_keyword = true,
            show_on_trigger_character = true,
        },

        list = {
            auto_insert = false,
            selection = {
                -- preselect = function(ctx) return not require("blink.cmp").snippet_active({ direction = 1 }) end,
                preselect = false,
            },
        },

        -- Menu appearance
        menu = {
            auto_show = true,
            draw = {
                -- Show kind icon, label, and source name in the menu
                columns = {
                    { "kind_icon" },
                    { "label", "label_description", gap = 1 },
                    { "source_name" },
                },
            },
        },

        -- Documentation popup
        documentation = {
            auto_show = true, -- show docs automatically when item selected
            auto_show_delay_ms = 200,
        },

        -- Ghost text: show the top completion inline as you type (like Copilot)
        ghost_text = { enabled = false },
    },

    -- ── Signature help ─────────────────────────────────────────────────────────
    -- Shows function signature while typing arguments
    signature = {
        enabled = true,
    },

    -- ── Cmdline completion ─────────────────────────────────────────────────────
    cmdline = {
        enabled = true, -- fuzzy completion in : command mode too
        keymap = { preset = "cmdline" },
        sources = { "cmdline" },
    },
})
