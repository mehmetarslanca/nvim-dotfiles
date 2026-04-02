return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "angular-language-server",
        "astro-language-server",
        "java-debug-adapter",
        "java-test",
        "jdtls",
        "json-lsp",
        "lua-language-server",
        "shfmt",
        "stylua",
        "tree-sitter-cli",
        "vtsls",
      },
      auto_update = false,
      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 24,
    },
  },
}
