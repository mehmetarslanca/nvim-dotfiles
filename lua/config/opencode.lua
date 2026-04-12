local M = {}

function M.is_sudo_frontend()
  return vim.env.NVIM_OPENCODE_FRONTEND == "sudo"
end

function M.port()
  local env_port = tonumber(vim.env.NVIM_OPENCODE_PORT)
  if env_port then
    return env_port
  end

  if M.is_sudo_frontend() then
    return 4097
  end

  return 4096
end

function M.url()
  return string.format("http://127.0.0.1:%d", M.port())
end

return M
