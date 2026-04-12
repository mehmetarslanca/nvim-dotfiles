return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = { enabled = false }, -- 99.nvim ile karışmaması için kapalı
        suggestion = {
          enabled = true,
          auto_trigger = true, -- Otomatik öneri aktif
          debounce = 75,
          keymap = {
            accept = "<C-Tab>", -- Tab akışını bozmadan öneriyi kabul et
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
      })
    end,
  },
}
