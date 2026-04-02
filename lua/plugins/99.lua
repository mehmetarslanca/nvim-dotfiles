return {
  {
    "ThePrimeagen/99",
    dependencies = {
      { "saghen/blink.compat", version = "2.*" },
    },
    keys = {
      {
        "<leader>9v",
        function()
          require("99").visual()
        end,
        mode = "v",
        desc = "99: Prompt with Visual Selection",
      },
      {
        "<leader>9x",
        function()
          require("99").stop_all_requests()
        end,
        desc = "99: Stop All Requests",
      },
      {
        "<leader>9s",
        function()
          require("99").search()
        end,
        desc = "99: Project Search (QFix)",
      },
    },
    config = function()
      local _99 = require("99")
      local Providers = require("99.providers")

      local function strip_ansi(text)
        if not text then
          return ""
        end

        return text:gsub("\r", ""):gsub("\27%[[0-9;?]*[ -/]*[@-~]", "")
      end

      local function emit_status(observer, chunk)
        if not observer or not observer.on_stdout or not chunk then
          return
        end

        local cleaned = strip_ansi(chunk)
        for _, line in ipairs(vim.split(cleaned, "\n", { trimempty = true })) do
          local text = vim.trim(line)
          if text ~= "" then
            observer.on_stdout(text)
          end
        end
      end

      if not Providers.OpenCodeProvider.__stderr_passthrough then
        Providers.OpenCodeProvider.make_request = function(self, query, context, observer)
          observer.on_start()

          local logger = context.logger:set_area(self:_get_provider_name())
          local stderr_chunks = {}
          local completed = false
          local command = self:_build_command(query, context)

          local function complete(status, text)
            if completed then
              return
            end

            completed = true
            observer.on_complete(status, text)
          end

          local proc = vim.system(command, {
            text = true,
            stdout = vim.schedule_wrap(function(err, data)
              if context:is_cancelled() then
                complete("cancelled", "")
                return
              end

              if err and err ~= "" then
                logger:debug("stdout#error", "err", err)
              end

              if not err and data then
                emit_status(observer, data)
              end
            end),
            stderr = vim.schedule_wrap(function(err, data)
              if context:is_cancelled() then
                complete("cancelled", "")
                return
              end

              if err and err ~= "" then
                logger:debug("stderr#error", "err", err)
              end

              if not err and data then
                table.insert(stderr_chunks, data)
                if observer.on_stderr then
                  observer.on_stderr(data)
                end
                emit_status(observer, data)
              end
            end),
          }, vim.schedule_wrap(function(obj)
            if context:is_cancelled() then
              complete("cancelled", "")
              return
            end

            if obj.code ~= 0 then
              complete("failed", string.format("process exit code: %d", obj.code))
              return
            end

            local ok, response = self:_retrieve_response(context)
            if not ok then
              complete("failed", "unable to retrieve response from temp file")
              return
            end

            if vim.trim(response) == "" then
              local stderr_text = vim.trim(strip_ansi(table.concat(stderr_chunks, "\n")))
              if stderr_text == "" then
                stderr_text = "response file was empty"
              end
              complete("failed", stderr_text)
              return
            end

            complete("success", response)
          end))

          context:_set_process(proc)
        end

        Providers.OpenCodeProvider.__stderr_passthrough = true
      end

      vim.fn.mkdir("tmp", "p")

      _99.setup({
        provider = Providers.OpenCodeProvider,
        model = "opencode/mimo-v2-pro-free",
        tmp_dir = "./tmp",
        completion = {
          source = "blink",
          files = {
            enabled = true,
          },
        },
      })
    end,
  },
}
