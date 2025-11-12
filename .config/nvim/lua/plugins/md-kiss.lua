-- Minimal Markdown + math workflow (FOSS/KISS):
-- - Blink completion of LaTeX symbols in Markdown
-- - :MdPdf for one-shot Pandoc -> PDF (LuaLaTeX) and open in Zathura (auto-reload)
-- - :MdWatch / :MdWatchStop to rebuild on save via `entr`
return {
  -- Markdown gets LaTeX symbol completion (inserts \alpha, not α)
  {
    "Saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.per_filetype = vim.tbl_deep_extend("force", opts.sources.per_filetype or {}, {
        markdown = { inherit_defaults = true, "latex_symbols" },
      })
      return opts
    end,
  },

  -- Ensure Treesitter grammars for Markdown editing
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, lang in ipairs { "markdown", "markdown_inline" } do
        if not vim.tbl_contains(opts.ensure_installed, lang) then table.insert(opts.ensure_installed, lang) end
      end
    end,
  },

  -- Commands + keymaps
  {
    "AstroNvim/astrocore",
    init = function()
      local function have(bin) return vim.fn.executable(bin) == 1 end

      local function pandoc_cmd(input_md)
        local stem = input_md:gsub("%.md$", "")
        local md = vim.fn.shellescape(input_md)
        local pdf = vim.fn.shellescape(stem .. ".pdf")
        local cmd = ("pandoc %s -o %s --from=markdown+tex_math_dollars+raw_tex --pdf-engine=lualatex --citeproc"):format(
          md,
          pdf
        )
        return cmd, (stem .. ".pdf")
      end

      -- One-shot: build PDF and open Zathura once (it auto-reloads)
      vim.api.nvim_create_user_command("MdPdf", function()
        if not have "pandoc" then
          vim.notify("MdPdf: pandoc not found. Install pandoc.", vim.log.levels.ERROR)
          return
        end
        local name = vim.api.nvim_buf_get_name(0)
        if name == "" or not name:match "%.md$" then
          vim.notify("MdPdf: open a Markdown (*.md) file", vim.log.levels.WARN)
          return
        end
        local cmd, pdf = pandoc_cmd(name)
        vim.fn.jobstart({ "sh", "-c", cmd }, {
          detach = true,
          on_exit = function()
            if have "zathura" and not vim.g._mdpdf_zathura_opened then
              vim.g._mdpdf_zathura_opened = true
              vim.fn.jobstart({ "zathura", "--fork", pdf }, { detach = true })
            end
          end,
        })
      end, {})

      -- Continuous: watch with entr and rebuild on change
      vim.api.nvim_create_user_command("MdWatch", function()
        if not have "pandoc" then
          vim.notify("MdWatch: pandoc not found. Install pandoc.", vim.log.levels.ERROR)
          return
        end
        if not have "entr" then
          vim.notify("MdWatch: entr not found. Install entr.", vim.log.levels.ERROR)
          return
        end
        local buf = vim.api.nvim_get_current_buf()
        local name = vim.api.nvim_buf_get_name(buf)
        if name == "" or not name:match "%.md$" then
          vim.notify("MdWatch: open a Markdown (*.md) file", vim.log.levels.WARN)
          return
        end

        -- First build (also opens Zathura once)
        vim.cmd "MdPdf"

        local cmd, _ = pandoc_cmd(name)
        local qfile = vim.fn.shellescape(name)
        local pipeline = ("printf %%s\\n %s | entr -r sh -c %s"):format(qfile, vim.fn.shellescape(cmd))
        local jobid = vim.fn.jobstart({ "sh", "-c", pipeline }, { detach = false })
        if jobid <= 0 then
          vim.notify("MdWatch: failed to start entr", vim.log.levels.ERROR)
          return
        end
        vim.b.md_kiss_watch_job = jobid
        vim.notify("MdWatch: watching " .. name .. " (use :MdWatchStop to stop)", vim.log.levels.INFO)

        -- Auto-stop when buffer unloads
        vim.api.nvim_create_autocmd({ "BufUnload", "BufWipeout" }, {
          buffer = buf,
          once = true,
          callback = function()
            if vim.b.md_kiss_watch_job then pcall(vim.fn.jobstop, vim.b.md_kiss_watch_job) end
          end,
        })
      end, {})

      vim.api.nvim_create_user_command("MdWatchStop", function()
        local job = vim.b.md_kiss_watch_job
        if job then
          pcall(vim.fn.jobstop, job)
          vim.b.md_kiss_watch_job = nil
          vim.notify("MdWatch: stopped", vim.log.levels.INFO)
        else
          vim.notify("MdWatch: no watcher running for this buffer", vim.log.levels.WARN)
        end
      end, {})

      -- Buffer-local keymaps for Markdown
      local group = vim.api.nvim_create_augroup("md_kiss_keys", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "markdown",
        callback = function(args)
          vim.keymap.set("n", "<leader>mP", "<cmd>MdPdf<CR>", { buffer = args.buf, desc = "Markdown → PDF (Pandoc)" })
          vim.keymap.set("n", "<leader>mw", "<cmd>MdWatch<CR>", { buffer = args.buf, desc = "Watch & rebuild (entr)" })
          vim.keymap.set("n", "<leader>mW", "<cmd>MdWatchStop<CR>", { buffer = args.buf, desc = "Stop watch" })
        end,
      })
    end,
  },
}
