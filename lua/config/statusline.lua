-- vim:foldmethod=marker

local utils = require "config.utils"

-- vim.o.laststatus = 3

-- Boilerplate init {{{
local components = {
    left = {
        active = {},
        inactive = {},
    },
    mid = {
        active = {},
        inactive = {},
    },
    right = {
        active = {},
        inactive = {},
    },
}
-- }}}

-- Vi Mode {{{
local vi_mode_colors = {
    NORMAL = "green",
    OP = "green",
    INSERT = "blue",
    VISUAL = "yellow",
    LINES = "yellow",
    BLOCK = "yellow",
    REPLACE = "red",
    ["V-REPLACE"] = "red",
    ENTER = "cyan",
    MORE = "cyan",
    SELECT = "orange",
    COMMAND = "purple",
    SHELL = "purple",
    TERM = "purple",
    NONE = "orange",
}

-- local short_vim_mode = {
--     NORMAL = "N",
--     OP = "O",
--     INSERT = "I",
--     VISUAL = "V",
--     LINES = "L",
--     BLOCK = "B",
--     REPLACE = "R",
--     ["V-REPLACE"] = "VR",
--     ENTER = "E",
--     MORE = "M",
--     SELECT = "S",
--     COMMAND = "C",
--     SHELL = "SH",
--     TERM = "T",
--     NONE = "-",
-- }
-- }}}

-- Left {{{
-- Vim mode
components.left.active[#components.left.active + 1] = {
    provider = function()
        local vim_mode = require("feline.providers.vi_mode").get_vim_mode()
        return " " .. vim_mode .. " "
    end,
    hl = function()
        return {
            name = require("feline.providers.vi_mode").get_mode_highlight_name(),
            bg = require("feline.providers.vi_mode").get_mode_color(),
            fg = "black",
            style = "bold",
        }
    end,
}

-- File Icon
components.left.active[#components.left.active + 1] = {
    provider = function(component)
        local _, icon = require("feline.providers.file").file_info(component, {})
        return "  " .. icon.str
    end,
    hl = function()
        local _, icon = require("feline.providers.file").file_info({}, {})
        return {
            fg = icon.hl.fg,
            bg = "section_bg",
        }
    end,
}
-- Filename
components.left.active[#components.left.active + 1] = {
    provider = function(component)
        local file_info, _ = require("feline.providers.file").file_info(component, { right_sep = " ", type = "unique" })
        return file_info .. " "
    end,
    hl = {
        fg = "blue",
        bg = "section_bg",
    },
}

-- Blank component for background styling purposes
components.left.active[#components.left.active + 1] = {
    provider = function()
        return ""
    end,
    hl = { bg = "NONE" },
}

-- LSP Diagnostics
components.left.active[#components.left.active + 1] = {
    provider = "diagnostic_errors",
    enabled = function()
        return require("feline.providers.lsp").diagnostics_exist(vim.diagnostic.severity.ERROR)
    end,
    hl = {
        fg = "red",
        style = "bold",
    },
}
components.left.active[#components.left.active + 1] = {
    provider = "diagnostic_warnings",
    enabled = function()
        return require("feline.providers.lsp").diagnostics_exist(vim.diagnostic.severity.WARN)
    end,
    hl = {
        fg = "orange",
        style = "bold",
    },
}
components.left.active[#components.left.active + 1] = {
    provider = "diagnostic_hints",
    enabled = function()
        return require("feline.providers.lsp").diagnostics_exist(vim.diagnostic.severity.HINT)
    end,
    hl = {
        fg = "blue",
        style = "bold",
    },
}
components.left.active[#components.left.active + 1] = {
    provider = "diagnostic_info",
    enabled = function()
        return require("feline.providers.lsp").diagnostics_exist(vim.diagnostic.severity.INFO)
    end,
    hl = {
        fg = "blue",
        style = "bold",
    },
}
-- }}}

-- Middle {{{
-- Language servers
components.mid.active[#components.mid.active + 1] = {
    provider = "lsp_client_names",
    hl = {
        fg = "middlegrey",
        style = "italic",
    },
}
-- }}}

-- Right {{{
-- Git diff
components.right.active[#components.right.active + 1] = {
    provider = "git_diff_added",
    icon = "+",
    hl = {
        fg = "green",
    },
    right_sep = " ",
}
components.right.active[#components.right.active + 1] = {
    provider = "git_diff_changed",
    icon = "~",
    hl = {
        fg = "yellow",
    },
    right_sep = " ",
}
components.right.active[#components.right.active + 1] = {
    provider = "git_diff_removed",
    icon = "-",
    hl = {
        fg = "red",
    },
    right_sep = " ",
}

-- Git branch
components.right.active[#components.right.active + 1] = {
    provider = "git_branch",
    hl = {
        fg = "purple",
        bg = "section_bg",
    },
    icon = "  ",
}

-- Separator
components.right.active[#components.right.active + 1] = {
    provider = " ",
    hl = {
        bg = "section_bg",
    },
}

-- Filetype
components.right.active[#components.right.active + 1] = {
    provider = function()
        return "  " .. vim.o.ft .. " "
    end,
    enabled = function()
        return vim.o.ft
    end,
    hl = { fg = "blue", bg = "section_bg" },
}

-- Folder
components.right.active[#components.right.active + 1] = {
    provider = function()
        return "  " .. vim.fn.expand "%:p:h:t" .. " "
    end,
    hl = { fg = "blue", bg = "section_bg" },
}

-- Cursor percent
components.right.active[#components.right.active + 1] = {
    provider = function()
        local curr_line = vim.fn.line "."
        local lines = vim.fn.line "$"

        return " " .. string.format("%2d%%%%", vim.fn.round(curr_line / lines * 100))
    end,
    hl = { fg = "darkgrey", bg = "blue" },
}

-- Line & Col number
components.right.active[#components.right.active + 1] = {
    provider = function()
        local line = vim.fn.line "."
        local col = vim.fn.col "."
        local total = vim.fn.line "$"
        return "  " .. string.format("%d/%d :%d ", line, total, col)
    end,
    hl = { fg = "darkgrey", bg = "blue" },
}

-- Word count
components.right.active[#components.right.active + 1] = {
    provider = function()
        local word_count = vim.fn.wordcount()
        local words = word_count.visual_words or word_count.words
        return "  " .. string.format("%d Words ", words)
    end,
    enabled = function()
        local show_word_count_filetypes = { "txt", "markdown", "pandoc" }
        return utils.contains(show_word_count_filetypes, vim.o.ft)
    end,
    hl = { fg = "darkgrey", bg = "blue" },
}
-- }}}

-- Inactive {{{
-- https://github.com/famiu/feline.nvim#disable-inactive-statusline
-- Get highlight of inactive statusline by parsing the style, fg and bg of VertSplit
local InactiveStatusHL = {
    fg = vim.api.nvim_exec("highlight VertSplit", true):match "guifg=(#[0-9A-Fa-f]+)" or "#444444",
    bg = vim.api.nvim_exec("highlight VertSplit", true):match "guibg=(#[0-9A-Fa-f]+)" or "NONE",
    style = vim.api.nvim_exec("highlight VertSplit", true):match "gui=(#[0-9A-Fa-f]+)" or "",
}

-- Add strikethrough to inactive statusline highlight style
-- in order to have a thin line instead of the statusline
if InactiveStatusHL.style == "" then
    InactiveStatusHL.style = "strikethrough"
else
    InactiveStatusHL.style = InactiveStatusHL.style .. ",strikethrough"
end

-- Apply the highlight to the statusline
-- by having an empty provider with the highlight
components.left.inactive[1] = {
    provider = "",
    hl = InactiveStatusHL,
}
-- }}}

-- Colors {{{
-- local everforest_palette = vim.api.nvim_eval "everforest#get_palette(everforest#get_configuration().background)"
local everforest_palette = vim.api.nvim_eval "everforest#get_palette('medium', {})"
for k, v in pairs(everforest_palette) do
    everforest_palette[k] = v[1]
end
local colors = {
    white = everforest_palette.fg,
    blue = everforest_palette.blue,
    green = everforest_palette.green,
    purple = everforest_palette.purple,
    orange = everforest_palette.orange,
    red = everforest_palette.red,
    yellow = everforest_palette.yellow,
    darkgrey = everforest_palette.bg0,
    middlegrey = "#8791A5", -- couldn't really find a suitable replacement
    section_bg = everforest_palette.bg1,
    fg = everforest_palette.fg,
    bg = everforest_palette.none,
}
-- local colors = {
--     white = "#cccccc",
--     blue = "#61afef",
--     green = "#98c379",
--     purple = "#c678dd",
--     orange = "#f29718",
--     red = "#e06c75",
--     yellow = "#e5c07b",
--     darkgrey = "#2c323d",
--     middlegrey = "#8791A5",
--     section_bg = "#38393f",
--     fg = "#D0D0D0",
--     bg = "NONE",
-- }
-- }}}

require("feline").setup {
    theme = colors,
    -- slight hack to deal with the new way of defining statuslines
    components = {
        active = { components.left.active, components.mid.active, components.right.active },
        inactive = { components.left.inactive, components.right.inactive },
    },
    vi_mode_colors = vi_mode_colors,
}
