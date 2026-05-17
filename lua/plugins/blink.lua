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
    -- 'default' preset: C-y accept, C-n/C-p navigate, C-e dismiss, C-space open
    -- 'super-tab': Tab/S-Tab navigate+accept (VSCode-style)
    -- 'enter': Enter to accept
    keymap = {
        preset = "super-tab",
        -- You can add overrides on top of the preset:
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
    },

    -- ── Completion behaviour ───────────────────────────────────────────────────
    completion = {
        -- Trigger: show menu automatically as you type
        trigger = {
            show_on_keyword = true,
            show_on_trigger_character = true,
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

        -- Auto-insert brackets after accepting a function completion
        accept = {
            auto_brackets = { enabled = true },
        },

        list = {
            selection = {
                preselect = true, -- pre-highlight first item
                auto_insert = false, -- don't insert until you explicitly accept
            },
        },
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
