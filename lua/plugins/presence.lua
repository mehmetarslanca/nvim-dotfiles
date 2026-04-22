-- Discord Rich Presence for Neovim
local function is_opencode_buffer(buf)
  buf = buf or vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  local filetype = vim.bo[buf].filetype
  local buftype = vim.bo[buf].buftype
  local name = vim.api.nvim_buf_get_name(buf):lower()

  if filetype == "opencode" or filetype == "opencode_ask" then
    return true
  end

  if buftype == "terminal" and name:find("opencode", 1, true) then
    return true
  end

  return name:find("opencode", 1, true) ~= nil
end

local function is_trackable_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) or is_opencode_buffer(buf) then
    return false
  end

  local name = vim.api.nvim_buf_get_name(buf)
  local buftype = vim.bo[buf].buftype

  return name ~= "" and (buftype == "" or buftype == "acwrite")
end

local function socket_exists(path)
  return path ~= nil and (vim.uv or vim.loop).fs_stat(path) ~= nil
end

local function find_linux_discord_socket()
  local runtime_dir = vim.env.XDG_RUNTIME_DIR

  if not runtime_dir or runtime_dir == "" then
    runtime_dir = string.format("/run/user/%d", vim.fn.getuid())
  end

  local roots = {
    runtime_dir,
    runtime_dir .. "/app/com.discordapp.Discord",
    runtime_dir .. "/app/com.discordapp.DiscordCanary",
    runtime_dir .. "/app/dev.vencord.Vesktop",
    runtime_dir .. "/app/dev.vencord.vesktop",
    runtime_dir .. "/app/com.vesktop.Vesktop",
  }

  for _, root in ipairs(roots) do
    for i = 0, 9 do
      local socket = string.format("%s/discord-ipc-%d", root, i)
      if socket_exists(socket) then
        return socket
      end
    end
  end
end

return {
  "andweeb/presence.nvim",
  event = "VeryLazy", -- Load when Neovim is ready
  opts = {
    -- General options
    auto_update = true, -- Update activity based on autocmd events
    neovim_image_text = "The One True Text Editor", -- Text displayed when hovered over the Neovim image
    main_image = "neovim", -- Main image display ("neovim" or "file")
    client_id = "793271441293967371", -- Discord application client id
    log_level = nil, -- "debug", "info", "warn", or "error"
    debounce_timeout = 10, -- Seconds to debounce events
    enable_line_number = false, -- Displays line number instead of project
    blacklist = {}, -- List of patterns to disable Rich Presence
    buttons = true, -- Enable/disable buttons or provide custom table
    file_assets = {}, -- Custom file asset definitions
    show_time = true, -- Show the timer

    -- Rich Presence text options
    editing_text = "Editing %s", -- Format string for editing
    file_explorer_text = "Browsing %s", -- Format string for file explorers
    git_commit_text = "Committing changes", -- Format string for git commits
    plugin_manager_text = "Managing plugins", -- Format string for plugin managers
    reading_text = "Reading %s", -- Format string for read-only files
    workspace_text = "Working on %s", -- Format string for git repositories
    line_number_text = "Line %s out of %s", -- Format string for line numbers
  },
  config = function(_, opts)
    local Presence = require("presence")
    local original_get_discord_socket_path = Presence.get_discord_socket_path

    function Presence:get_discord_socket_path()
      local socket = original_get_discord_socket_path(self)

      if socket_exists(socket) then
        return socket
      end

      if self.os and self.os.name == "linux" then
        local flatpak_socket = find_linux_discord_socket()
        if flatpak_socket then
          return flatpak_socket
        end
      end

      return socket
    end

    Presence = Presence:setup(opts)
    local state = {
      last_real_buffer = nil,
    }
    local original_cancel = Presence.cancel
    local original_update_for_buffer = Presence.update_for_buffer

    local current_buf = vim.api.nvim_get_current_buf()
    if is_trackable_buffer(current_buf) then
      state.last_real_buffer = vim.api.nvim_buf_get_name(current_buf)
    end

    function Presence:cancel(...)
      self.last_activity.file = nil
      return original_cancel(self, ...)
    end

    function Presence:update_for_buffer(buffer, should_debounce)
      local buf = vim.api.nvim_get_current_buf()

      if is_trackable_buffer(buf) then
        state.last_real_buffer = buffer
      elseif is_opencode_buffer(buf) then
        if not state.last_real_buffer then
          return
        end

        buffer = state.last_real_buffer
      end

      return original_update_for_buffer(self, buffer, should_debounce)
    end
  end,
}
