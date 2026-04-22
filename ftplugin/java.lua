local ok, jdtls = pcall(require, "jdtls")
if not ok then
  return
end

local function build_bundles()
  local bundles = vim.fn.glob("$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin-*jar", false, true)
  vim.list_extend(bundles, vim.fn.glob("$MASON/share/java-test/*.jar", false, true))
  return bundles
end

local function build_capabilities()
  local has_blink, blink = pcall(require, "blink.cmp")
  if has_blink then
    return blink.get_lsp_capabilities()
  end
end

local function start_jdtls()
  local cmd = vim.fn.exepath("jdtls")
  if cmd == "" then
    vim.notify("jdtls executable not found in PATH", vim.log.levels.ERROR)
    return
  end

  local root_dir = vim.fs.root(0, {
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    "mvnw",
    "gradlew",
    ".git",
  })

  if not root_dir then
    return
  end

  local project_name = vim.fs.basename(root_dir)
  local full_cmd = { cmd }
  local lombok_jar = vim.fn.expand("$MASON/share/jdtls/lombok.jar")

  if lombok_jar ~= "" and (vim.uv or vim.loop).fs_stat(lombok_jar) then
    table.insert(full_cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
  end

  vim.list_extend(full_cmd, {
    "-configuration",
    vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config",
    "-data",
    vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace",
  })

  jdtls.start_or_attach({
    cmd = full_cmd,
    root_dir = root_dir,
    init_options = {
      bundles = build_bundles(),
    },
    capabilities = build_capabilities(),
    settings = {
      java = {
        inlayHints = {
          parameterNames = {
            enabled = "all",
          },
        },
      },
    },
  })
end

vim.schedule(start_jdtls)
