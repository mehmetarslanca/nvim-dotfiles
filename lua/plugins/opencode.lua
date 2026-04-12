local opencode_config = require("config.opencode")

return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  cond = function()
    return not opencode_config.is_sudo_frontend()
  end,
  dependencies = {
    {
      "folke/snacks.nvim",
      optional = true,
      opts = {
        picker = {
          actions = {
            opencode_send = function(...)
              return require("opencode").snacks_picker_send(...)
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    local port = opencode_config.port()
    local command = string.format("opencode --port %d", port)

    -- Opencode genel ayarları
    vim.g.opencode_opts = {
      server = {
        port = port,
        start = function()
          require("opencode.terminal").open(command, {
            split = "right",
            width = math.floor(vim.o.columns * 0.35),
          })
        end,
        toggle = function()
          require("opencode.terminal").toggle(command, {
            split = "right",
            width = math.floor(vim.o.columns * 0.35),
          })
        end,
      },
    }

    -- Dosyalar dışarıdan (AI tarafından) değiştirildiğinde otomatik yenilenmesi için gerekli
    vim.o.autoread = true

    -- Tuş Atamaları
    -- Ctrl+a: Seçili alanı veya imlecin olduğu yeri sorar
    vim.keymap.set({ "n", "x" }, "<C-a>", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode..." })

    -- Ctrl+x: Opencode aksiyonlarını listeler (seçim ekranı)
    vim.keymap.set({ "n", "x" }, "<C-x>", function()
      require("opencode").select()
    end, { desc = "Execute opencode action..." })

    -- leader+oc: Opencode penceresini aç/kapat
    vim.keymap.set({ "n", "t" }, "<leader>oc", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })

    -- Operatör eşleşmeleri (go + hareket ile seçim yapmanızı sağlar)
    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { desc = "Add range to opencode", expr = true })

    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Add line to opencode", expr = true })
  end,
}
