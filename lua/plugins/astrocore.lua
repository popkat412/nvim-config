-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    -- filetypes = {
    --   -- see `:h vim.filetype.add` for usage
    --   extension = {
    --     foo = "fooscript",
    --   },
    --   filename = {
    --     [".foorc"] = "fooscript",
    --   },
    --   pattern = {
    --     [".*/etc/foo/.*"] = "fooscript",
    --   },
    -- },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
        -- custom stuff below
        confirm = true, -- if something is running ask to quit
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- Make option+j/k move lines down/up (https://stackoverflow.com/a/2439848)
        ["∆"] = [[mz:m+<CR>`z==]],
        ["˚"] = [[mz:m-2<CR>`z==]],
      },
      v = {
        -- Make option+j/k move lines down/up
        ["∆"] = [[:m'>+<CR>gv=`<my`>mzgv`yo`z]],
        ["˚"] = [[:m'<-2<CR>gv=`>my`<mzgv`yo`z]],
      },
      i = {
        -- Make option+j/k move lines down/up
        ["∆"] = [[<Esc>:m+<CR>==gi]],
        ["˚"] = [[<Esc>:m-2<CR>==gi]],
      },
      t = {
        -- map jk and <Esc> to exit insert mode
        ["jk"] = [[<C-\><C-n>]],
        ["<Esc>"] = [[<C-\><C-n>]],
        -- unbind <C-l> from "move to right window" so that it gets passed to the shell and lets me clear the screen insetad
        ["<C-l>"] = false,
      },
    },
    commands = {
      -- https://chatgpt.com/s/t_69100b0a33f4819197fe404314681240
      -- Basically
      Wqa = {
        function(c)
          -- HELPER FUNCTIONS --
          -- How it decides “something is running”:
          --     For each terminal buffer, get the shell PID (jobpid).
          --     If pgrep -P <pid> returns any child PIDs → active (foreground job).
          --     If pgrep isn’t available, it parses ps and treats any non-zombie child as active.
          --     If any terminal is active, it aborts and shows which buffers are busy.
          --     If none are active, it politely closes the shells and quits.

          local function system_lines(cmd)
            -- prefer vim.system (NVIM 0.10+), fallback to fn.systemlist
            if vim.system then
              local res = vim.system(cmd, { text = true }):wait()
              if res.code == 0 and res.stdout then
                local t = {}
                for line in res.stdout:gmatch "[^\r\n]+" do
                  table.insert(t, line)
                end
                return t
              else
                return {}
              end
            else
              -- 0.9 fallback
              local out = vim.fn.systemlist(table.concat(cmd, " "))
              return (vim.v.shell_error == 0 and out) or {}
            end
          end

          local function has_active_child(pid)
            if not pid then return false end

            -- Fast path: pgrep -P <pid> (macOS has pgrep)
            local children = system_lines { "pgrep", "-P", tostring(pid) }
            if #children > 0 then return true end

            -- Fallback: parse ps output for children with this PPID
            local lines = system_lines { "ps", "-axo", "pid=,ppid=,stat=,comm=" }
            for _, line in ipairs(lines) do
              local cpid, ppid, stat, comm = line:match "^%s*(%d+)%s+(%d+)%s+(%S+)%s+(.+)$"
              if tonumber(ppid) == pid then
                -- Ignore zombies & trivial helpers; any real child = active
                local is_zombie = stat:find("Z", 1, true) ~= nil
                local trivial = comm:match "^%-?$" or comm:match "^ps$"
                if not is_zombie and not trivial then return true end
              end
            end
            return false
          end

          local function collect_terminal_jobs()
            local terms = {}
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "terminal" then
                local ch = vim.b[bufnr].terminal_job_id
                local pid = ch and vim.fn.jobpid(ch) or nil
                table.insert(terms, { buf = bufnr, chan = ch, pid = pid })
              end
            end
            return terms
          end

          -- ACTUAL COMMAND CODE --
          vim.cmd "wall"

          local busy = {}
          local terms = collect_terminal_jobs()
          for _, t in ipairs(terms) do
            if t.pid and has_active_child(t.pid) then table.insert(busy, t) end
          end

          if #busy > 0 then
            -- Abort quit and tell the user which terminal buffers are busy
            local msg = { "Abort quit: active process detected in terminal buffer(s):" }
            for _, t in ipairs(busy) do
              local name = (vim.api.nvim_buf_get_name(t.buf) or ""):gsub("^.+/", "")
              table.insert(msg, ("  • buf %d  %s"):format(t.buf, name ~= "" and name or "[terminal]"))
            end
            vim.notify(table.concat(msg, "\n"), vim.log.levels.WARN, { title = "Wqa" })
            return
          end

          -- No active children: politely close idle shells and delete terminal buffers
          for _, t in ipairs(terms) do
            if t.chan then
              pcall(vim.fn.chansend, t.chan, "\x04") -- EOT (Ctrl-D)
              pcall(vim.fn.chansend, t.chan, "exit\r") -- fallback
              pcall(vim.fn.jobwait, { t.chan }, 200)
            end
            pcall(vim.api.nvim_buf_delete, t.buf, { force = true })
          end

          -- Finally quit all
          vim.cmd(c.bang and "qa!" or "qa")
        end,
        bang = true,
        desc = "Write all & quit if terminals idle; abort if any running",
      },
    },
    autocmds = {
      disable_autocomment = {
        { -- autocmd BufNewFile,BufRead * setlocal formatoptions-=cro
          event = { "BufNewFile", "BufRead" },
          desc = "Disable contination of comments on o/enter",
          callback = function()
            vim.opt_local.formatoptions:remove "c"
            vim.opt_local.formatoptions:remove "r"
            vim.opt_local.formatoptions:remove "o"
          end,
        },
      },
    },
  },
}
