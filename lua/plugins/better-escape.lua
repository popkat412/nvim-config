return {
  "max397574/better-escape.nvim",
  event = "VeryLazy",
  opts = function (_, opts)
    opts.mappings = {
      i = { j = { k = "<Esc>" } },
    }
  end,
}
