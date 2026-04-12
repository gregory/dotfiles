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

return {
  -- Disable NvChad's bundled indent-blankline: it hooks ColorScheme and
  -- crashes on gruvbox (which doesn't define IblChar). We don't use it.
  { "lukas-reineke/indent-blankline.nvim", enabled = false },

  -- nvim-treesitter: NvChad pins this but on nvim 0.12 an old checkout
  -- crashes inside query_predicates.lua ("attempt to call method
  -- 'range' (a nil value)") as soon as an injection is parsed —
  -- anything with a markdown fenced code block, including CopilotChat
  -- responses. Force lazy.nvim to follow master so :Lazy sync picks up
  -- the upstream fix, and run :TSUpdate on build so parsers stay in
  -- sync with the query schema.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })()
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
      { "<C-g>", "<cmd>FzfLua live_grep<CR>", desc = "FZF live grep" },
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
      winopts = { preview = { default = "bat" } },
      previewers = {
        bat = {
          cmd = "bat",
          args = "--color=always --style=numbers,changes",
          -- Theme is controlled dynamically via BAT_THEME env var, set in
          -- user.tweak_common() so it tracks vim.o.background.
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
      { "s", function() require("flash").jump() end,       mode = { "n", "x", "o" }, desc = "Flash jump" },
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
  -- Use `-` to bounce up directories like in netrw.
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Oil (parent dir)" },
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
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "gj", function() gs.nav_hunk("next") end, opts)
        vim.keymap.set("n", "gk", function() gs.nav_hunk("prev") end, opts)
        -- Moved off <leader>h* to free that prefix for flash line motion.
        -- New prefix: <leader>G (uppercase, since ,g* is fugitive/fzf-lua).
        vim.keymap.set("n", "<leader>Gp", gs.preview_hunk, opts)
        vim.keymap.set("n", "<leader>Gs", gs.stage_hunk, opts)
        vim.keymap.set("n", "<leader>Gb", function() gs.blame_line({ full = true }) end, opts)
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
    cmd = {
      "G", "Git", "Gread", "Gwrite", "Ggrep",
      "Gdiffsplit", "Gvdiffsplit", "GMove", "GDelete", "GRemove", "GdiffInTab",
    },
  },
  { "scrooloose/nerdcommenter" },
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
  -- Prereq: :Copilot setup (already configured above).
  --
  -- Usage:
  --   ,cc  -> open chat sidebar (ask anything about current buffer)
  --   ,ce  -> explain selection (visual mode) or current function
  --   ,cf  -> fix diagnostic on current line
  --   ,ct  -> generate tests for selection/function
  --   ,cr  -> review code for issues
  --   ,cp  -> prompt palette (browse pre-built prompts)
  {
    "CopilotC-Nvim/CopilotChat.nvim",
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
      { "<leader>cc", "<cmd>CopilotChatToggle<CR>",  mode = { "n", "x" }, desc = "Copilot chat toggle" },
      { "<leader>ce", "<cmd>CopilotChatExplain<CR>", mode = { "n", "x" }, desc = "Copilot explain" },
      { "<leader>cf", "<cmd>CopilotChatFix<CR>",     mode = { "n", "x" }, desc = "Copilot fix" },
      { "<leader>ct", "<cmd>CopilotChatTests<CR>",   mode = { "n", "x" }, desc = "Copilot tests" },
      { "<leader>cr", "<cmd>CopilotChatReview<CR>",  mode = { "n", "x" }, desc = "Copilot review" },
      { "<leader>co", "<cmd>CopilotChatOptimize<CR>", mode = { "n", "x" }, desc = "Copilot optimize" },
      { "<leader>cd", "<cmd>CopilotChatDocs<CR>",    mode = { "n", "x" }, desc = "Copilot docs" },
      { "<leader>cp", "<cmd>CopilotChatPrompts<CR>", mode = { "n", "x" }, desc = "Copilot prompt palette" },
    },
    opts = {
      -- gpt-4o wasn't enabled on this Copilot plan. claude-3.5-sonnet is
      -- available and handles code tasks very well.
      model = "claude-3.5-sonnet",
      window = {
        layout = "vertical",
        width = 0.4,
      },
      show_help = true,
      auto_insert_mode = true,
      -- Treesitter markdown injections crash on nvim 0.12 with older
      -- nvim-treesitter checkouts. Turn them off in the chat buffer so
      -- CopilotChat works even if the parser update hasn't landed.
      highlight_headers = false,
      highlight_selection = false,
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)
      -- Belt-and-braces: disable treesitter highlighter in copilot-chat
      -- buffers to bypass any lingering query-predicate crash.
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

  -- Statusline
  {
    "itchyny/lightline.vim",
    config = function()
      require("user.lightline").setup()
    end,
  },

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
