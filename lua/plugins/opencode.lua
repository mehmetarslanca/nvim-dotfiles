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
    local function terminal_opts()
      return {
        split = "right",
        width = math.floor(vim.o.columns * 0.35),
      }
    end

    local function with_attached_tui(open_fn)
      if not opencode_config.ensure_server_started() then
        vim.notify(
          string.format("OpenCode server did not become ready on %s", opencode_config.url()),
          vim.log.levels.ERROR,
          { title = "opencode" }
        )
        return
      end

      open_fn(opencode_config.attach_command(), terminal_opts())
    end

    -- Opencode genel ayarları
    vim.g.opencode_opts = {
      server = {
        port = port,
        start = function()
          with_attached_tui(function(command, opts)
            require("opencode.terminal").open(command, opts)
          end)
        end,
        stop = function()
          require("opencode.terminal").close()
        end,
        toggle = function()
          with_attached_tui(function(command, opts)
            require("opencode.terminal").toggle(command, opts)
          end)
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
