local M = {}
local host = "127.0.0.1"

local function has_env(name)
  local value = vim.env[name]
  return value ~= nil and value ~= ""
end

function M.is_sudo_frontend()
  return has_env("NVIM_OPENCODE_FRONTEND") and vim.env.NVIM_OPENCODE_FRONTEND == "sudo"
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

function M.host()
  return host
end

function M.url()
  return string.format("http://%s:%d", M.host(), M.port())
end

function M.attach_command()
  return string.format(
    "opencode attach %s --dir %s",
    vim.fn.shellescape(M.url()),
    vim.fn.shellescape(vim.fn.getcwd())
  )
end

local function run_system(command)
  if vim.system then
    return vim.system(command, { text = true }):wait(2000)
  end

  local output = vim.fn.system(command)
  return {
    code = vim.v.shell_error,
    stdout = output,
    stderr = "",
  }
end

function M.server_is_ready()
  if vim.fn.executable("curl") ~= 1 then
    return false
  end

  local result = run_system({ "curl", "-fsS", string.format("%s/session", M.url()) })
  return result.code == 0
end

function M.start_server()
  return vim.fn.jobstart({
    "opencode",
    "serve",
    "--hostname",
    M.host(),
    "--port",
    tostring(M.port()),
  }, { detach = 1 })
end

function M.ensure_server_started()
  if M.server_is_ready() then
    return true
  end

  local job_id = M.start_server()
  if job_id <= 0 then
    return false
  end

  return vim.wait(5000, function()
    return M.server_is_ready()
  end, 100)
end

return M
