-- Helper: take the list of items returned by a fzf-lua buf-scoped picker
-- (lgrep_curbuf, blines, ...), extract their line numbers, and trigger
-- flash.jump so each of those lines gets a label in the current buffer.
local function flash_on_fzf_results(selected, _opts)
  if not selected or #selected == 0 then return end
  local lines = {}
  local seen = {}
  for _, item in ipairs(selected) do
    -- strip ANSI colors and fzf-lua icons/prefixes
    local clean = item:gsub("\27%[[%d;]*m", "")
    -- lgrep_curbuf / blines format is "<lnum>:<col>:<text>" or
    -- "<lnum><tab><text>", with optional icon prefix. Grab the first
    -- standalone number as line number.
    local lnum = clean:match("(%d+)%s*:%s*%d+") -- "lnum:col:..."
               or clean:match("%f[%d](%d+)")    -- first integer
    if lnum then
      local n = tonumber(lnum)
      if n and not seen[n] then
        seen[n] = true
        table.insert(lines, n)
      end
    end
  end
  if #lines == 0 then return end
  -- Defer so fzf-lua is fully closed before flash grabs the window.
  vim.schedule(function()
    require("flash").jump({
      search = { multi_window = false },
      label = { after = { 0, 0 } },
      matcher = function(win)
        local buf = vim.api.nvim_win_get_buf(win)
        local total = vim.api.nvim_buf_line_count(buf)
        local matches = {}
        for _, lnum in ipairs(lines) do
          if lnum >= 1 and lnum <= total then
            local text = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ""
            local col = (text:find("%S") or 1) - 1
            table.insert(matches, {
              pos     = { lnum, col },
              end_pos = { lnum, col },
            })
          end
        end
        return matches
      end,
      action = function(match)
        vim.api.nvim_win_set_cursor(match.win, { match.pos[1], match.pos[2] })
      end,
    })
  end)
end

-- ============================================================
-- Custom labeled-jump ("smart flash").
--
-- Behaves like flash.nvim's `s`, with one extra trick:
--   1. press `s`
--   2. type one or more chars to filter visible matches
--   3. while the label overlay is live:
--        <Space>   -> page down (<C-f>), refresh labels
--        <S-Space> -> page up   (<C-b>), refresh labels
--   4. press the label letter of your target to jump there
--
-- flash.nvim's prompt is a blocking char-reader that doesn't expose
-- key hooks, so we reimplement the minimum needed with extmarks.
-- ============================================================
local function smart_flash()
  local ns         = vim.api.nvim_create_namespace("smart_flash")
  local all_labels = "asdfghjklqwertyuiopzxcvbnm"
  local pattern    = ""
  local buf        = vim.api.nvim_get_current_buf()
  local win        = vim.api.nvim_get_current_win()

  local t_esc   = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  local t_bs    = vim.api.nvim_replace_termcodes("<BS>",  true, false, true)
  local t_sspc  = vim.api.nvim_replace_termcodes("<S-Space>", true, false, true)
  local t_cf    = vim.api.nvim_replace_termcodes("<C-f>", true, true, true)
  local t_cb    = vim.api.nvim_replace_termcodes("<C-b>", true, true, true)

  local function scroll(keys)
    -- "nx" = no remap + execute synchronously so the viewport is
    -- updated before we loop back and recompute matches.
    vim.api.nvim_feedkeys(keys, "nx", false)
  end

  local function clear()
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end

  local function available_labels()
    local out, seen = {}, {}
    for c in pattern:lower():gmatch(".") do seen[c] = true end
    for i = 1, #all_labels do
      local c = all_labels:sub(i, i)
      if not seen[c] then table.insert(out, c) end
    end
    return out
  end

  local function find_matches_for(pat)
    if pat == "" then return {} end
    local first   = vim.fn.line("w0")
    local last    = vim.fn.line("w$")
    local pat_esc = vim.pesc(pat:lower())
    local out     = {}
    for lnum = first, last do
      local line  = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ""
      local lower = line:lower()
      local start = 1
      while true do
        local s = lower:find(pat_esc, start, false)
        if not s then break end
        table.insert(out, { lnum = lnum, col = s - 1 })
        start = s + 1
      end
      if #out >= #all_labels then break end
    end
    return out
  end

  local function find_matches() return find_matches_for(pattern) end

  local function render(matches, labels)
    clear()
    for i, m in ipairs(matches) do
      local label = labels[i]
      if not label then break end
      -- Highlight the match itself in yellow.
      pcall(vim.api.nvim_buf_set_extmark, buf, ns, m.lnum - 1, m.col, {
        end_col    = math.min(m.col + #pattern,
                       #(vim.api.nvim_buf_get_lines(buf, m.lnum - 1, m.lnum, false)[1] or "")),
        hl_group   = "FlashMatch",
        priority   = 65534,
      })
      -- Overlay the jump label on top of the match's first char.
      pcall(vim.api.nvim_buf_set_extmark, buf, ns, m.lnum - 1, m.col, {
        virt_text         = { { label, "FlashLabel" } },
        virt_text_pos     = "overlay",
        hl_mode           = "combine",
        priority          = 65535,
      })
    end
  end

  while true do
    local matches = find_matches()
    local labels  = available_labels()
    render(matches, labels)
    vim.cmd("redraw")

    local ok, ch = pcall(vim.fn.getcharstr)
    if not ok or ch == "" or ch == t_esc then
      clear(); return
    end

    -- Backspace: shrink pattern.
    if ch == t_bs then
      if #pattern > 0 then pattern = pattern:sub(1, -2) end
      goto continue
    end

    -- Space / Shift-Space (or <C-f>/<C-b> as terminal-proof fallback):
    -- scroll viewport, BUT only after the user has typed at least one
    -- pattern char (otherwise `s<Space>` would surprise-scroll).
    if #pattern > 0 then
      if ch == " " or ch == t_cf then
        clear()
        scroll(t_cf)
        goto continue
      end
      if ch == t_sspc or ch == t_cb then
        clear()
        scroll(t_cb)
        goto continue
      end
    end

    -- Only treat printable chars past this point.
    if #ch ~= 1 or ch:byte() < 32 or ch:byte() >= 127 then
      goto continue
    end

    -- Prefer extending the pattern over jumping: if appending ch still
    -- has matches, it's a refinement. Otherwise, ch is interpreted as
    -- a jump label — this is how easymotion/flash disambiguate.
    do
      local trial = pattern .. ch
      local trial_matches = find_matches_for(trial)
      if #trial_matches > 0 then
        pattern = trial
        goto continue
      end
    end

    -- No extended match — ch must be a label (or noise).
    if #matches > 0 then
      for i, label in ipairs(labels) do
        if ch == label and matches[i] then
          clear()
          vim.api.nvim_win_set_cursor(win, { matches[i].lnum, matches[i].col })
          return
        end
      end
    end
    -- Unrecognized char: ignore and keep prompting.

    ::continue::
  end
end

return {
  -- Disable NvChad's bundled indent-blankline: it hooks ColorScheme and
  -- crashes on gruvbox (which doesn't define IblChar). We don't use it.
  { "lukas-reineke/indent-blankline.nvim", enabled = false },

  -- Colorschemes used by F1 / F3. F2 keeps gruvbox-light (already loaded
  -- by NvChad via morhetz/gruvbox). We load these eagerly so F-keys never
  -- hit a missing-colorscheme error on first press.
  { "xero/miasma.nvim",      lazy = false, priority = 900 },
  { "maxmx03/solarized.nvim", lazy = false, priority = 900 },

  -- nvim-treesitter on the `main` branch.
  --
  -- This was pinned to `branch = "master"` with a custom build, and the result
  -- was ZERO installed parsers. Two reasons:
  --   1. NvChad v2.5 speaks the `main` API only — its :TSInstallAll runs
  --      `require("nvim-treesitter").install(...)`, and on master that function
  --      does not exist (the module exports just setup/define_modules/statusline).
  --   2. The custom build called install.update(), which only refreshes parsers
  --      that are ALREADY installed. With none installed it succeeded on an
  --      empty set — a silent no-op, not an error.
  -- master is also frozen upstream ("provided for backward compatibility only"),
  -- so the query_predicates crash the old comment here described was never going
  -- to be fixed there. And master's setup() takes no arguments at all, so there
  -- is no way to express ensure_installed through a lazy.nvim spec on it.
  --
  -- Requires the tree-sitter CLI (brew install tree-sitter-cli) — `main`
  -- compiles each parser locally. Note brew's `tree-sitter` formula ships no
  -- bin/; the CLI is the separate `tree-sitter-cli` formula.
  --
  -- Highlighting itself needs nothing from this plugin: NvChad runs
  -- `pcall(vim.treesitter.start)` on FileType *, which is nvim-core
  -- highlighting and only wants a parser on the runtimepath. What this plugin
  -- does provide is plugin/filetypes.lua, which registers the ft->lang aliases
  -- core lacks — without it .jsx and .sh get nothing even with parsers present.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- so plugin/filetypes.lua is sourced before any FileType fires
    build = ":TSUpdate",
    opts = {
      -- NvChad's five (lua/luadoc/printf/vim/vimdoc) must be repeated here:
      -- lazy.nvim merges opts with tbl_deep_extend("force", ...), which on an
      -- array table overwrites index-by-index rather than appending.
      ensure_installed = {
        -- what actually gets edited here (js 3366, jsx 1541, mjs 1038, md 540,
        -- ts 425, json 407, html 404, sh 288, vue 268, sql 241, yml 117)
        "javascript", "jsdoc", "typescript", "tsx", "vue",
        "html", "css", "scss",
        -- no separate "jsonc" parser on this branch; the json parser serves
        -- jsonc through an ft alias.
        "json", "yaml", "toml",
        "bash", "sql", "regex",
        "markdown", "markdown_inline",
        "ruby", "embedded_template",
        "terraform", "hcl",
        -- editing this config, and living in git
        "lua", "luadoc", "vim", "vimdoc", "query", "printf",
        "diff", "gitcommit", "git_rebase", "gitignore", "dockerfile",
        -- deliberately NOT "comment": it injects into every comment in every
        -- buffer and is measurable on large JS files.
        -- there is no "jsx" parser — javascript handles JSX via the
        -- javascriptreact -> javascript alias.
      },
    },
    config = function(_, opts)
      local ts = require "nvim-treesitter"
      ts.setup {}
      -- :TSUpdate (like master's update()) only touches parsers already
      -- installed, so install the missing ones explicitly. NvChad's
      -- :TSInstallAll reads this same opts.ensure_installed.
      local installed = ts.get_installed "parsers"
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, opts.ensure_installed)
      if #missing > 0 then
        ts.install(missing)
      end
    end,
  },

  -- ============================================================
  -- Core
  -- ============================================================
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- ============================================================
  -- Navigation / search — modernized
  -- ============================================================

  -- Fuzzy finder (replaces fzf.vim)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      { "<CR>", "<cmd>FzfLua git_files<CR>", desc = "FZF git files" },
      {
        "<C-g>",
        function()
          local f = vim.api.nvim_buf_get_name(0)
          local dir = (f ~= "" and vim.fn.fnamemodify(f, ":p:h")) or vim.fn.getcwd()
          local root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel")[1]
          local cwd = (vim.v.shell_error == 0 and root ~= "") and root or dir
          require("fzf-lua").live_grep({ cwd = cwd })
        end,
        desc = "FZF live grep (git root)",
      },
      -- ? = search in current buffer. Press <c-l> after typing a query to
      -- close fzf and flash-jump to any of the matches directly in the
      -- buffer (each hit gets a big flash label).
      {
        "?",
        function()
          require("fzf-lua").lgrep_curbuf({
            actions = {
              ["ctrl-l"] = { fn = flash_on_fzf_results },
            },
            keymap = {
              fzf = {
                ["ctrl-l"] = "select-all+accept",
              },
            },
          })
        end,
        desc = "FZF buffer lines (+ <c-l> to flash-jump)",
      },
      { "mru", "<cmd>FzfLua oldfiles<CR>", desc = "FZF MRU" },
      { "ge", "<cmd>FzfLua grep_project<CR>", desc = "FZF grep project" },
      { "gs", "<cmd>FzfLua git_status<CR>", desc = "FZF git status" },
      { "M", "<cmd>FzfLua marks<CR>", desc = "FZF marks" },
      -- Buffer list (replaces CtrlSpace List)
      { "<S-Tab>", "<cmd>FzfLua buffers<CR>", desc = "FZF buffers (all open)" },
      { "<Tab>", "<cmd>FzfLua buffers<CR>", desc = "FZF buffers (all open)" },
    },
    opts = {
      -- Use the builtin (nvim-window) previewer instead of bat so the
      -- mouse wheel scrolls the preview natively. Syntax highlighting
      -- comes from nvim's own colorscheme / treesitter, which means it
      -- automatically tracks F1/F2/F3 without BAT_THEME juggling.
      winopts = {
        preview = {
          default      = "builtin",
          scrollbar    = "float",
          scrollchars  = { "┃", "" },
        },
      },
      -- fzf has a native "jump" mode (basically easymotion for the result
      -- list). Once you have results, press <c-s> to label every visible
      -- line with a letter, type the letter to select+accept instantly.
      fzf_opts = {
        ["--jump-labels"] = "asdfghjklqwertyuiopzxcvbnm",
      },
      keymap = {
        fzf = {
          ["ctrl-d"] = "half-page-down",
          ["ctrl-u"] = "half-page-up",
          ["ctrl-a"] = "select-all+accept",
          ["ctrl-s"] = "jump-accept", -- flash-style jump to any result
          ["alt-s"]  = "jump",        -- jump without accepting (just move)
          -- Preview scroll (works regardless of terminal shift-arrow support)
          ["ctrl-f"] = "preview-page-down",
          ["ctrl-b"] = "preview-page-up",
          ["alt-j"]  = "preview-down",
          ["alt-k"]  = "preview-up",
          -- Shift-arrows still work as a fallback on capable terminals
          ["shift-down"] = "preview-page-down",
          ["shift-up"]   = "preview-page-up",
        },
      },
    },
  },

  -- Visual jumping (replaces vim-easymotion)
  -- Mirrors the old vimrc bindings:
  --   s   -> flash jump anywhere in the window (was EasyMotion#OverwinF(2))
  --   ,l  -> jump forward  on the current line   (easymotion-lineforward)
  --   ,h  -> jump backward on the current line   (easymotion-linebackward)
  --   ,j  -> jump to any line below the cursor   (easymotion-j)
  --   ,k  -> jump to any line above the cursor   (easymotion-k)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      label = { uppercase = false, rainbow = { enabled = false } },
      modes = {
        -- Enable labels on / and ? results. As you type the search, every
        -- visible match gets a letter — press the letter to jump straight
        -- there (no more cycling with n/N). <CR> still accepts the first
        -- match like normal search.
        search = {
          enabled = true,
          highlight = { backdrop = false },
          incremental = true,
        },
        char = { enabled = false }, -- don't hijack f/F/t/T
      },
    },
    keys = {
      { "s", smart_flash,                                   mode = { "n", "x", "o" }, desc = "Smart flash (space scrolls)" },
      { "S", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Flash treesitter" },
      { "r", function() require("flash").remote() end,     mode = "o",               desc = "Remote flash" },

      -- easymotion-lineforward / linebackward: restrict to current line
      {
        "<leader>l",
        function()
          local line = vim.api.nvim_win_get_cursor(0)[1]
          require("flash").jump({
            search = { forward = true, wrap = false, multi_window = false, max_length = 0 },
            pattern = ".",
            matcher = function(win)
              local buf = vim.api.nvim_win_get_buf(win)
              local text = vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1] or ""
              local cur_col = vim.api.nvim_win_get_cursor(win)[2]
              local matches = {}
              for col = cur_col + 1, #text - 1 do
                table.insert(matches, {
                  pos = { line, col },
                  end_pos = { line, col },
                })
              end
              return matches
            end,
          })
        end,
        mode = { "n", "x", "o" },
        desc = "Flash line forward",
      },
      {
        "<leader>h",
        function()
          local line = vim.api.nvim_win_get_cursor(0)[1]
          require("flash").jump({
            search = { forward = false, wrap = false, multi_window = false, max_length = 0 },
            pattern = ".",
            matcher = function(win)
              local buf = vim.api.nvim_win_get_buf(win)
              local text = vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1] or ""
              local cur_col = vim.api.nvim_win_get_cursor(win)[2]
              local matches = {}
              for col = 0, cur_col - 1 do
                if col < #text then
                  table.insert(matches, {
                    pos = { line, col },
                    end_pos = { line, col },
                  })
                end
              end
              return matches
            end,
          })
        end,
        mode = { "n", "x", "o" },
        desc = "Flash line backward",
      },

      -- easymotion-j / k: jump to any line below / above
      {
        "<leader>j",
        function()
          require("flash").jump({
            search = { mode = "search", max_length = 0, forward = true, wrap = false, multi_window = false },
            pattern = "^",
            label = { after = { 0, 0 } },
          })
        end,
        mode = { "n", "x", "o" },
        desc = "Flash line below",
      },
      {
        "<leader>k",
        function()
          require("flash").jump({
            search = { mode = "search", max_length = 0, forward = false, wrap = false, multi_window = false },
            pattern = "^",
            label = { after = { 0, 0 } },
          })
        end,
        mode = { "n", "x", "o" },
        desc = "Flash line above",
      },
    },
  },

  -- ============================================================
  -- GitHub Copilot (inline AI suggestions)
  -- ============================================================
  -- Shows grey ghost-text as you type. Does NOT collide with coc.nvim
  -- because coc uses a popup menu and copilot uses virtual text.
  --
  -- First-time setup (after :Lazy sync):
  --   :Copilot setup   -> opens a browser to authenticate your GitHub
  --                       account. Follow the device-code flow.
  --   :Copilot status  -> verify it says "Enabled"
  --   :Copilot disable / :Copilot enable  -> per-session toggle
  {
    "github/copilot.vim",
    event = "InsertEnter",
    cmd = "Copilot", -- also load when :Copilot is called (needed for setup)
    init = function()
      -- Use the language server VENDORED with this plugin instead of npx.
      --
      -- Without this, s:Command() in autoload/copilot/client.vim prefers npx
      -- unconditionally (copilot_npx_command defaults to 1) and asks for
      -- `@github/copilot-language-server@^<version>` — a CARET range, so npm
      -- re-resolves the newest 1.x on EVERY launch. Measured in lsp.log:
      -- 1.515 -> 1.517 -> 1.521 -> 1.526, with 7s, 8s and once 92s before
      -- Copilot became usable, plus a 608MB ~/.npm/_npx cache.
      --
      -- The vendored dist/language-server.js only needs the platform binary
      -- on node < 22; on node >= 22 it just require()s ./main. We're on v24.
      -- Set in `init` (not `config`) so it lands before the first client start.
      vim.g.copilot_npx_command = 0
    end,
    config = function()
      -- Disable the default <Tab> mapping so it doesn't fight coc.
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      -- File-type allowlist: enable everywhere by default.
      vim.g.copilot_filetypes = {
        ["*"] = true,
        gitcommit = true,
        markdown = true,
        yaml = true,
      }
      -- IMPORTANT: <C-l>/<C-j> are already bound to coc-snippets
      -- (expand / expand-jump). Copilot uses a DIFFERENT set so the two
      -- systems coexist:
      --   <C-y>   accept full suggestion (mnemonic: "yes")
      --   <M-l>   accept the next word only
      --   <M-]>   next suggestion variant
      --   <M-[>   previous variant
      --   <C-]>   dismiss the current ghost text
      vim.keymap.set("i", "<C-y>", 'copilot#Accept("\\<CR>")', {
        expr = true, replace_keycodes = false, silent = true, desc = "Copilot accept",
      })
      vim.keymap.set("i", "<M-l>", "<Plug>(copilot-accept-word)", { silent = true, desc = "Copilot accept word" })
      vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)",        { silent = true, desc = "Copilot next suggestion" })
      vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)",    { silent = true, desc = "Copilot previous suggestion" })
      vim.keymap.set("i", "<C-]>", "<Plug>(copilot-dismiss)",     { silent = true, desc = "Copilot dismiss" })
    end,
  },

  -- Pinned buffers (replaces vim-ctrlspace workspaces)
  -- Harpoon = 4-5 fichiers que tu épingles et auxquels tu sautes vite.
  -- Pour la liste *complète* des buffers ouverts, voir <S-Tab> -> FzfLua buffers ci-dessus.
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- Moved off <leader>h* to free that prefix for flash line motion.
    -- New prefix: <leader>p (pin).
    keys = {
      { "<leader>pa", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
      { "<leader>pp", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon menu" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon 4" },
    },
    config = function()
      require("harpoon"):setup()
    end,
  },

  -- File explorer sidebar (replaces nerdtree). neo-tree = vraie sidebar persistante.
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      -- ,m  -> open rooted at the current file's directory (neo-tree will
      --        close if already open thanks to the toggle verb).
      -- ,n  -> same, but also reveal/select the file inside the tree.
      -- We build the dir= arg dynamically so switching buffers re-roots
      -- the tree to wherever the active buffer lives.
      {
        "<leader>m",
        function()
          local file = vim.api.nvim_buf_get_name(0)
          local dir = (file ~= "" and vim.fn.isdirectory(file) == 0)
            and vim.fn.fnamemodify(file, ":p:h")
            or vim.fn.getcwd()
          vim.cmd("Neotree toggle left dir=" .. vim.fn.fnameescape(dir))
        end,
        desc = "Neo-tree toggle (rooted at current file dir)",
      },
      {
        "<leader>n",
        function()
          local file = vim.api.nvim_buf_get_name(0)
          local dir = (file ~= "" and vim.fn.isdirectory(file) == 0)
            and vim.fn.fnamemodify(file, ":p:h")
            or vim.fn.getcwd()
          vim.cmd("Neotree toggle reveal left dir=" .. vim.fn.fnameescape(dir))
        end,
        desc = "Neo-tree toggle + reveal (rooted at current file dir)",
      },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true, leave_dirs_open = false },
        -- Don't let neo-tree lock its root to the nvim cwd — we pass
        -- dir= explicitly from the keymaps, and we want that to win.
        bind_to_cwd = false,
        cwd_target = { sidebar = "window", current = "window" },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { "node_modules", ".git" },
        },
      },
      window = { width = 35 },
    },
  },

  -- Quick "edit parent dir as a buffer" (kept alongside neo-tree).
  -- `-` used to bounce up dirs (netrw-style) but was reassigned to
  -- alternate-buffer switching. Use `_` (shift+`-`) instead.
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
      { "_", "<cmd>Oil<CR>", desc = "Oil (parent dir)" },
    },
    opts = {
      default_file_explorer = false,
      view_options = { show_hidden = true },
    },
  },

  -- Session restore per project
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { dir = vim.fn.stdpath("state") .. "/sessions/" },
  },

  -- Git hunks (replaces vim-signify)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "+" },
        change       = { text = "~" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function desc(d) return { buffer = bufnr, silent = true, desc = d } end

        -- Hunk navigation (bare, same letter as `]c`/`[c` but keeps the
        -- `g*` git namespace).
        vim.keymap.set("n", "gj", function() gs.nav_hunk("next") end, desc("Next git hunk"))
        vim.keymap.set("n", "gk", function() gs.nav_hunk("prev") end, desc("Prev git hunk"))

        -- <leader>G* — hunk ops. ,g* is reserved for fugitive/fzf-lua.
        --   Gp preview · Gs stage · Gr reset · Gu undo stage
        --   GS stage-buffer · GR reset-buffer
        --   Gb blame-line · Gt toggle inline blame virttext
        --   Gq all project hunks → quickfix (same as :GdiffQF shortcut)
        --   Gd diff this buffer vs index · GD vs last commit
        vim.keymap.set("n", "<leader>Gp", gs.preview_hunk,          desc("Preview hunk"))
        vim.keymap.set("n", "<leader>Gs", gs.stage_hunk,            desc("Stage hunk"))
        vim.keymap.set("n", "<leader>Gr", gs.reset_hunk,            desc("Reset hunk"))
        vim.keymap.set("n", "<leader>Gu", gs.undo_stage_hunk,       desc("Undo stage hunk"))
        vim.keymap.set("n", "<leader>GS", gs.stage_buffer,          desc("Stage buffer"))
        vim.keymap.set("n", "<leader>GR", gs.reset_buffer,          desc("Reset buffer"))
        vim.keymap.set("n", "<leader>Gb", function() gs.blame_line({ full = true }) end, desc("Blame line (popup)"))
        vim.keymap.set("n", "<leader>Gt", gs.toggle_current_line_blame, desc("Toggle inline blame"))
        vim.keymap.set("n", "<leader>Gd", gs.diffthis,              desc("Diff this vs index"))
        vim.keymap.set("n", "<leader>GD", function() gs.diffthis("~") end, desc("Diff this vs last commit"))
        vim.keymap.set("n", "<leader>Gq", function()
          gs.setqflist("all", { use_location_list = false })
        end, desc("All hunks → quickfix"))

        -- Visual-mode hunk ops: stage/reset a precise line range.
        vim.keymap.set("v", "<leader>Gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, desc("Stage selected lines"))
        vim.keymap.set("v", "<leader>Gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, desc("Reset selected lines"))
      end,
    },
  },

  -- ============================================================
  -- Utilities kept
  -- ============================================================
  {
    "mbbill/undotree",
    name = "undotree",
    cmd = { "UndotreeToggle", "UndotreeShow" },
  },
  {
    "tpope/vim-fugitive",
    name = "vim-fugitive",
    -- Lazy-load on the commands we actually invoke. `Gclog`/`0Gclog` are
    -- the log-into-quickfix entry points (bound to `gh`). `GBrowse` comes
    -- from vim-rhubarb (declared as a separate plugin) but needs fugitive
    -- loaded first — adding it here ensures the `<leader>gy/gY` bindings
    -- work on first invocation.
    cmd = {
      "G", "Git", "Gread", "Gwrite", "Ggrep",
      "Gdiffsplit", "Gvdiffsplit", "GMove", "GDelete", "GRemove",
      "GdiffInTab", "GdiffQF",
      "Gclog",
      "GBrowse",
    },
  },
  { "scrooloose/nerdcommenter", lazy = false },
  { "stefandtw/quickfix-reflector.vim" },
  { "editorconfig/editorconfig-vim" },
  { "moll/vim-node" },
  { "tpope/vim-rhubarb" },
  { "terryma/vim-multiple-cursors" },

  -- coc.nvim kept for now — migration to native LSP deferred.
  -- coc_global_extensions auto-installs the listed CoC extensions on
  -- first launch so `:CocInstall` is not required. coc-snippets gives
  -- us tabstop-aware expansion; honza/vim-snippets is the actual
  -- snippet corpus (thousands of JS/TS/React/Ruby/Python/… templates).
  {
    "neoclide/coc.nvim",
    branch = "release",
    init = function()
      vim.g.coc_global_extensions = {
        "coc-snippets",
        "coc-json",
        "coc-tsserver",
        "coc-eslint",
        "coc-prettier",
        "coc-css",
        "coc-html",
        "coc-yaml",
      }
    end,
  },
  { "honza/vim-snippets" },

  -- ============================================================
  -- Copilot Chat: sidebar conversation powered by your Copilot sub
  -- ============================================================
  -- DISABLED: your Copilot token doesn't include Chat ("chat not
  -- enabled for IDE token"). To re-enable:
  --   1. Check your plan on github.com/settings/copilot
  --   2. Run :Copilot setup to re-auth with chat scope
  --   3. Change `enabled = false` to `true` below
  --
  -- Usage (once enabled):
  --   ,cc  -> open chat sidebar (normal mode only — visual ,cc = nerdcommenter)
  --   ,ce  -> explain selection (visual mode) or current function
  --   ,cf  -> fix diagnostic on current line
  --   ,ct  -> generate tests for selection/function
  --   ,cr  -> review code for issues
  --   ,cp  -> prompt palette (browse pre-built prompts)
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = true,
    dependencies = {
      "github/copilot.vim",
      "nvim-lua/plenary.nvim",
    },
    cmd = {
      "CopilotChat", "CopilotChatOpen", "CopilotChatToggle",
      "CopilotChatExplain", "CopilotChatReview", "CopilotChatFix",
      "CopilotChatOptimize", "CopilotChatDocs", "CopilotChatTests",
      "CopilotChatCommit", "CopilotChatPrompts",
    },
    keys = {
      -- ,cc in normal = Copilot chat; in visual = nerdcommenter (see below)
      { "<leader>cc", "<cmd>CopilotChatToggle<CR>",  mode = "n",          desc = "Copilot chat toggle" },
      { "<leader>ce", "<cmd>CopilotChatExplain<CR>", mode = { "n", "x" }, desc = "Copilot explain" },
      { "<leader>cf", "<cmd>CopilotChatFix<CR>",     mode = { "n", "x" }, desc = "Copilot fix" },
      { "<leader>ct", "<cmd>CopilotChatTests<CR>",   mode = { "n", "x" }, desc = "Copilot tests" },
      { "<leader>cr", "<cmd>CopilotChatReview<CR>",  mode = { "n", "x" }, desc = "Copilot review" },
      { "<leader>co", "<cmd>CopilotChatOptimize<CR>", mode = { "n", "x" }, desc = "Copilot optimize" },
      { "<leader>cd", "<cmd>CopilotChatDocs<CR>",    mode = { "n", "x" }, desc = "Copilot docs" },
      { "<leader>cp", "<cmd>CopilotChatPrompts<CR>", mode = { "n", "x" }, desc = "Copilot prompt palette" },
    },
    opts = {
      -- First run: :CopilotChatModels to pick your model, then
      -- hardcode it here (uncomment + replace):
      -- model = "claude-3.5-sonnet",
      window = { layout = "vertical", width = 0.4 },
      show_help = true,
      auto_insert_mode = true,
      -- Built-in chat buffer keymaps:
      --   <C-s>  send (insert)    <CR>   send (normal)
      --   gd     show diff        <C-y>  accept diff
      --   gy     yank code block  gj     jump to diff
      --   q      close            <C-c>  close (insert)
      mappings = {
        submit_prompt = { normal = "<CR>", insert = "<C-s>" },
        close         = { normal = "q",    insert = "<C-c>" },
        reset         = { normal = "<C-r>" },
        accept_diff   = { normal = "<C-y>", insert = "<C-y>" },
        show_diff     = { normal = "gd" },
        yank_diff     = { normal = "gy" },
        jump_to_diff  = { normal = "gj" },
      },
      -- Custom prompts available as /DocsInline and /FixInline in chat
      prompts = {
        DocsInline = {
          prompt = "> /COPILOT_GENERATE\n\nAdd documentation comments to the selected code. Return the ENTIRE selected code with documentation added. Do NOT remove or change any existing code, ONLY add doc comments.",
          description = "Add docs (generates applicable diff)",
        },
        FixInline = {
          prompt = "> /COPILOT_GENERATE\n\nFix any issues in the selected code. Return the ENTIRE code with fixes applied. Do NOT remove code that doesn't need fixing.",
          description = "Fix code (generates applicable diff)",
        },
      },
      highlight_headers = false,
      highlight_selection = false,
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")
      opts.selection = select.visual
      chat.setup(opts)

      -- ,cD / ,cF: trigger the custom prompts on visual selection
      vim.keymap.set("x", "<leader>cD", function()
        chat.ask("/DocsInline", { selection = select.visual })
      end, { silent = true, desc = "Copilot add docs (diff)" })

      vim.keymap.set("x", "<leader>cF", function()
        chat.ask("/FixInline", { selection = select.visual })
      end, { silent = true, desc = "Copilot fix code (diff)" })

      -- Disable treesitter in chat buffers to work around nvim 0.12
      -- query-predicate crash on markdown injections.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "copilot-chat",
        callback = function()
          pcall(vim.treesitter.stop)
        end,
      })
    end,
  },
  { "honza/vim-snippets" },

  { "hashivim/vim-terraform" },
  { "tpope/vim-endwise" },
  { "Chiel92/vim-autoformat" },
  { "tpope/vim-repeat" },
  { "tpope/vim-surround" },
  { "kana/vim-submode" },
  { "jiangmiao/auto-pairs" },
  { "MattesGroeger/vim-bookmarks", lazy = false },
  { "kshenoy/vim-signature" },
  { "tomtom/tlib_vim" },
  { "sheerun/vim-polyglot" },
  { "marcweber/vim-addon-mw-utils" },
  { "junegunn/vim-easy-align", lazy = false },

  -- Colorscheme
  { "morhetz/gruvbox" },

  -- Statusline: using NvChad's built-in statusline (loaded via base46).
  -- lightline.vim removed — was conflicting and lacked Nerd Font icons.

  -- ============================================================
  -- REMOVED (see commit message for rationale):
  --   easymotion/vim-easymotion              -> flash.nvim
  --   phaazon/hop.nvim                       -> flash.nvim
  --   haya14busa/vim-asterisk                -> nvim native (mapped below)
  --   scrooloose/nerdtree                    -> oil.nvim
  --   szw/vim-ctrlspace                      -> harpoon2 + fzf-lua buffers
  --   junegunn/fzf, junegunn/fzf.vim         -> fzf-lua
  --   othree/yajs.vim                        -> polyglot handles JS
  --   vim-syntastic/syntastic                -> coc does linting
  --   juliosueiras/vim-terraform-completion  -> per plan decision
  --   cmather/vim-meteor-snippets            -> no Meteor
  --   rakr/vim-one, joshdick/onedark.vim     -> only gruvbox used
  -- ============================================================
}
