local ss = require("smart-splits")

ss.setup({
    ignored_filetypes = {
        "snacks_picker_list",
    },
    multiplexer_integration = "tmux",
})

-- these keymaps will also accept a range,
-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
vim.keymap.set("n", "<A-h>", ss.resize_left)
vim.keymap.set("n", "<A-j>", ss.resize_down)
vim.keymap.set("n", "<A-k>", ss.resize_up)
vim.keymap.set("n", "<A-l>", ss.resize_right)
-- moving between splits
vim.keymap.set("n", "<S-C-h>", ss.move_cursor_left)
vim.keymap.set("n", "<S-C-j>", ss.move_cursor_down)
vim.keymap.set("n", "<S-C-k>", ss.move_cursor_up)
vim.keymap.set("n", "<S-C-l>", ss.move_cursor_right)
vim.keymap.set("n", "<S-C-\\>", ss.move_cursor_previous)
-- swapping buffers between windows
vim.keymap.set("n", "<leader><leader>h", ss.swap_buf_left)
vim.keymap.set("n", "<leader><leader>j", ss.swap_buf_down)
vim.keymap.set("n", "<leader><leader>k", ss.swap_buf_up)
vim.keymap.set("n", "<leader><leader>l", ss.swap_buf_right)
