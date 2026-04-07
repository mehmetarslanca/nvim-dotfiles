return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "LazyFile",
    config = function()
      require("rainbow-delimiters.setup").setup({
        strategy = {
          [""] = "rainbow-delimiters.strategy.global",
          vim = "rainbow-delimiters.strategy.local",
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRose",
          "RainbowDelimiterTeal",
          "RainbowDelimiterLeaf",
          "RainbowDelimiterAmber",
          "RainbowDelimiterGold",
          "RainbowDelimiterSteel",
        },
      })
    end,
  },
}
