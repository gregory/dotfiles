return {
  -- Disable NvChad's bundled indent-blankline: it hooks ColorScheme and
  -- crashes on gruvbox (which doesn't define IblChar). We don't use it.
  { "lukas-reineke/indent-blankline.nvim", enabled = false },

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
      { "?", "<cmd>FzfLua lgrep_curbuf<CR>", desc = "FZF buffer lines" },
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

  -- Visual jumping (replaces vim-easymotion + hop.nvim)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = { enabled = false }, -- don't hijack / and ?
        char = { enabled = false }, -- don't hijack f/F/t/T
      },
    },
    keys = {
      { "s", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Flash jump" },
      { "S", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Flash treesitter" },
      { "r", function() require("flash").remote() end, mode = "o", desc = "Remote flash" },
    },
  },

  -- Pinned buffers (replaces vim-ctrlspace workspaces)
  -- Harpoon = 4-5 fichiers que tu épingles et auxquels tu sautes vite.
  -- Pour la liste *complète* des buffers ouverts, voir <S-Tab> -> FzfLua buffers ci-dessus.
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
      { "<leader>hh", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon menu" },
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
      { "<leader>m", "<cmd>Neotree toggle left<CR>", desc = "Neo-tree toggle" },
      { "<leader>n", "<cmd>Neotree toggle reveal left<CR>", desc = "Neo-tree toggle + reveal current file" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
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
        vim.keymap.set("n", "<leader>hp", gs.preview_hunk, opts)
        vim.keymap.set("n", "<leader>hs", gs.stage_hunk, opts)
        vim.keymap.set("n", "<leader>hb", function() gs.blame_line({ full = true }) end, opts)
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

  -- coc.nvim kept for now — migration to native LSP deferred
  { "neoclide/coc.nvim", branch = "release" },
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
