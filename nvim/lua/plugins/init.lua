return {
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
  {
    "mbbill/undotree",
    name = "undotree",
    cmd = { "UndotreeToggle", "UndotreeShow" },
  },
  {
    "tpope/vim-fugitive",
    name = "vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gread",
      "Gwrite",
      "Ggrep",
      "Gdiffsplit",
      "Gvdiffsplit",
      "GMove",
      "GDelete",
      "GRemove",
      "GdiffInTab",
    },
  },
  { "scrooloose/nerdcommenter" },
  { "stefandtw/quickfix-reflector.vim" },
  { "editorconfig/editorconfig-vim" },
  { "moll/vim-node" },
  { "tpope/vim-rhubarb" },
  { "terryma/vim-multiple-cursors" },
  {
    "neoclide/coc.nvim",
    branch = "release",
  },
  { "honza/vim-snippets" },
  { "hashivim/vim-terraform" },
  { "vim-syntastic/syntastic" },
  { "juliosueiras/vim-terraform-completion" },
  { "cmather/vim-meteor-snippets" },
  { "tpope/vim-endwise" },
  { "Chiel92/vim-autoformat" },
  { "tpope/vim-repeat" },
  { "tpope/vim-surround" },
  {
    "scrooloose/nerdtree",
    cmd = { "NERDTreeToggle", "NERDTreeFind" },
  },
  {
    "easymotion/vim-easymotion",
    lazy = false,
  },
  { "kana/vim-submode" },
  {
    "phaazon/hop.nvim",
    branch = "v2",
    config = function()
      require("hop").setup {}
    end,
  },
  { "jiangmiao/auto-pairs" },
  { "szw/vim-ctrlspace" },
  { "MattesGroeger/vim-bookmarks" },
  { "kshenoy/vim-signature" },
  { "haya14busa/vim-asterisk" },
  {
    "junegunn/fzf",
    build = "./install --all",
  },
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    lazy = false,
  },
  { "tomtom/tlib_vim" },
  { "sheerun/vim-polyglot" },
  { "othree/yajs.vim" },
  { "marcweber/vim-addon-mw-utils" },
  { "junegunn/vim-easy-align" },
  { "morhetz/gruvbox" },
  { "rakr/vim-one" },
  { "joshdick/onedark.vim" },
  {
    "itchyny/lightline.vim",
    config = function()
      require("user.lightline").setup()
    end,
  },
}
