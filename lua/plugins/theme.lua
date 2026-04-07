local palette = {
  rose = "#ff5b97",
  teal = "#35b6ab",
  leaf = "#9bbc40",
  amber = "#d69557",
  gold = "#d6b246",
  steel = "#adb8c8",
  ash = "#7c8087",
  bg = "#181818",
  bg_dark = "#141414",
}

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = function(_, opts)
      opts.transparent = true
      opts.styles = opts.styles or {}
      opts.styles.sidebars = "transparent"
      opts.styles.floats = "transparent"
      opts.on_colors = function(colors)
        colors.bg = palette.bg
        colors.bg_dark = palette.bg_dark
        colors.comment = palette.ash
      end
      opts.on_highlights = function(hl)
        hl.Keyword = { fg = palette.rose, bold = true }
        hl.Function = { fg = palette.leaf, bold = true }
        hl.Type = { fg = palette.teal, bold = true }
        hl.Identifier = { fg = palette.steel }
        hl.Comment = { fg = palette.ash, italic = true }
        hl.Constant = { fg = palette.amber }
        hl.String = { fg = palette.amber }
        hl.Number = { fg = palette.gold }
        hl.Boolean = { fg = palette.gold, bold = true }

        hl["@keyword"] = { fg = palette.rose, bold = true }
        hl["@keyword.function"] = { fg = palette.rose, bold = true }
        hl["@function"] = { fg = palette.leaf, bold = true }
        hl["@function.method"] = { fg = palette.leaf, bold = true }
        hl["@method"] = { fg = palette.leaf, bold = true }
        hl["@type"] = { fg = palette.teal, bold = true }
        hl["@type.builtin"] = { fg = palette.teal, bold = true }
        hl["@constructor"] = { fg = palette.teal, bold = true }
        hl["@parameter"] = { fg = palette.steel, italic = true }
        hl["@variable.parameter"] = { fg = palette.steel, italic = true }
        hl["@field"] = { fg = palette.amber }
        hl["@property"] = { fg = palette.amber }
        hl["@variable.member"] = { fg = palette.amber }
        hl["@attribute"] = { fg = palette.gold }
        hl["@annotation"] = { fg = palette.gold }
        hl["@constant"] = { fg = palette.amber }
        hl["@string"] = { fg = palette.amber }
        hl["@number"] = { fg = palette.gold }
        hl["@boolean"] = { fg = palette.gold, bold = true }

        hl["@lsp.type.method"] = { fg = palette.leaf, bold = true }
        hl["@lsp.type.type"] = { fg = palette.teal, bold = true }
        hl["@lsp.type.class"] = { fg = palette.teal, bold = true }
        hl["@lsp.type.interface"] = { fg = palette.teal, bold = true }
        hl["@lsp.type.parameter"] = { fg = palette.steel, italic = true }
        hl["@lsp.type.field"] = { fg = palette.amber }
        hl["@lsp.type.property"] = { fg = palette.amber }

        hl.RainbowDelimiterRose = { fg = palette.rose }
        hl.RainbowDelimiterTeal = { fg = palette.teal }
        hl.RainbowDelimiterLeaf = { fg = palette.leaf }
        hl.RainbowDelimiterAmber = { fg = palette.amber }
        hl.RainbowDelimiterGold = { fg = palette.gold }
        hl.RainbowDelimiterSteel = { fg = palette.steel }
      end
    end,
  },
}
