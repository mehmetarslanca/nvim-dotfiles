local opencode_config = require("config.opencode")

return {
  "sudo-tee/opencode.nvim",
  name = "sudo-tee-opencode.nvim",
  cond = function()
    return opencode_config.is_sudo_frontend()
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local port = opencode_config.port()
    local host = "127.0.0.1"

    require("opencode").setup({
      default_global_keymaps = false,
      server = {
        url = host,
        port = port,
        timeout = 5,
        spawn_command = function(server_port)
          return vim.fn.jobstart({
            "opencode",
            "serve",
            "--hostname",
            "127.0.0.1",
            "--port",
            tostring(server_port),
          }, { detach = 1 })
        end,
        kill_command = function(server_port)
          return vim.fn.jobstart({
            "pkill",
            "-f",
            string.format("opencode serve.*--port %d", server_port),
          }, { detach = 1 })
        end,
        auto_kill = true,
      },
      keymap = {
        editor = {
          ["<leader>oc"] = { "toggle" },
          ["<leader>oi"] = { "open_input" },
          ["<leader>oo"] = { "open_output" },
          ["<leader>os"] = { "select_session" },
          ["<leader>op"] = { "configure_provider" },
          ["<leader>oq"] = { "close" },
        },
      },
      ui = {
        position = "right",
        window_width = 0.4,
        input = {
          auto_hide = false,
        },
      },
    })

    vim.o.autoread = true
  end,
}
