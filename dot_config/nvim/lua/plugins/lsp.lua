return {
  -- Mason: installs LSP servers, formatters, DAP adapters
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = { icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } },
    },
  },

  -- mason-lspconfig bridges mason ↔ vim.lsp.enable
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls", "rust_analyzer", "ts_ls", "svelte",
        "html", "texlab", "marksman", "yamlls", "taplo",
        -- ltex managed via mason-tool-installer for version control
      },
      automatic_installation = false,
    },
  },

  -- mason-tool-installer: formatters, linters, DAP, extra servers
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- LSP servers
        "lua-language-server",
        "rust-analyzer",
        "typescript-language-server",
        "svelte-language-server",
        "html-lsp",
        "texlab",
        "marksman",
        "yaml-language-server",
        "taplo",
        "ltex-ls",
        -- Formatters
        "stylua",
        "prettier",
        -- rustfmt is managed by rustup, not mason
        "google-java-format",
        "djlint",
        -- DAP
        "codelldb",
        "js-debug-adapter",
        "java-debug-adapter",
        "java-test",
      },
      auto_update = false,
      run_on_start = true,
    },
    config = function(_, opts)
      require("mason-tool-installer").setup(opts)
      -- Enable servers after mason installs them
      -- Server configs loaded by init.lua (lua/lsp/*.lua)
      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsStartingInstall",
        once = true,
        callback = function()
          vim.schedule(function()
            vim.lsp.enable({
              "lua_ls", "rust_analyzer", "ts_ls", "svelte",
              "html", "texlab", "marksman", "yamlls", "taplo", "ltex",
            })
          end)
        end,
      })
      -- Also enable on startup (for machines where tools are already installed)
      vim.lsp.enable({
        "lua_ls", "rust_analyzer", "ts_ls", "svelte",
        "html", "texlab", "marksman", "yamlls", "taplo", "ltex",
      })
    end,
  },
}
