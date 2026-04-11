return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local jdtls = require("jdtls")
      local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
      local lombok_jar = jdtls_path .. "/lombok.jar"

      -- Find project root
      local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
      local root_dir = require("jdtls.setup").find_root(root_markers)
      if not root_dir then
        return
      end

      -- Unique workspace per project
      local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
      local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

      -- Find launcher jar and platform config
      local jdtls_launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      local jdtls_config_dir
      if vim.fn.has("linux") == 1 then
        jdtls_config_dir = jdtls_path .. "/config_linux"
      elseif vim.fn.has("mac") == 1 then
        jdtls_config_dir = jdtls_path .. "/config_mac"
      end

      local config = {
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xmx1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
          -- Lombok support
          vim.fn.filereadable(lombok_jar) == 1 and "-javaagent:" .. lombok_jar or nil,
          "-jar", jdtls_launcher,
          "-configuration", jdtls_config_dir,
          "-data", workspace_dir,
        },
        root_dir = root_dir,
        settings = {
          java = {
            eclipse = { downloadSources = true },
            configuration = { updateBuildConfiguration = "interactive" },
            maven = { downloadSources = true },
            implementationsCodeLens = { enabled = true },
            referencesCodeLens = { enabled = true },
            references = { includeDecompiledSources = true },
            inlayHints = { parameterNames = { enabled = "none" } }, -- too noisy for Java
            format = { enabled = true },
          },
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.junit.Assert.*",
              "org.junit.Assume.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.mockito.Mockito.*",
            },
          },
        },
        init_options = {
          bundles = (function()
            local b = {}
            vim.list_extend(b, vim.split(
              vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"),
              "\n", { trimempty = true }
            ))
            vim.list_extend(b, vim.split(
              vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-test/extension/server/*.jar"),
              "\n", { trimempty = true }
            ))
            return b
          end)(),
        },
        on_attach = function(client, bufnr)
          -- Enable navic for breadcrumbs
          local ok, navic = pcall(require, "nvim-navic")
          if ok then navic.attach(client, bufnr) end

          -- Java-specific keymaps
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Java: " .. desc })
          end
          map("<leader>jo", jdtls.organize_imports,                    "Organize imports")
          map("<leader>jv", jdtls.extract_variable,                    "Extract variable")
          map("<leader>jm", function() jdtls.extract_method(true) end, "Extract method")
          map("<leader>jc", "<cmd>!javac %<cr>",                       "Compile file")
          map("<leader>jf", jdtls.rename_file,                         "Rename file (+ class)")

          -- DAP: enable Java debugging if nvim-dap is available
          local ok_dap, dap = pcall(require, "jdtls.dap")
          if ok_dap then
            dap.setup_dap_main_class_configs()
          end
        end,
        capabilities = vim.lsp.protocol.make_client_capabilities(),
      }

      -- Filter nil from cmd array
      config.cmd = vim.tbl_filter(function(v) return v ~= nil end, config.cmd)

      jdtls.start_or_attach(config)
    end,
  },
}
