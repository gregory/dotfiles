local M = {}

function M.setup()
  require("lazy").setup({
    { "folke/lazy.nvim", version = false },
    { "mbbill/undotree" },
    { "tpope/vim-fugitive" },
    { "tpope/vim-rhubarb" },
    { "preservim/nerdcommenter" },
    { "stefandtw/quickfix-reflector.vim" },
    { "editorconfig/editorconfig-vim" },
    { "moll/vim-node" },
    { "terryma/vim-multiple-cursors" },
    {
      "neoclide/coc.nvim",
      branch = "release",
      build = "./install.sh nightly",
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
    { "preservim/nerdtree", cmd = { "NERDTreeToggle", "NERDTreeFind" } },
    { "easymotion/vim-easymotion" },
    { "kana/vim-submode" },
    { "haya14busa/incsearch.vim" },
    { "haya14busa/incsearch-fuzzy.vim" },
    { "haya14busa/incsearch-easymotion.vim" },
    { "jiangmiao/auto-pairs" },
    { "szw/vim-ctrlspace" },
    { "MattesGroeger/vim-bookmarks" },
    { "kshenoy/vim-signature" },
    { "haya14busa/vim-asterisk" },
    {
      "junegunn/fzf",
      build = "./install --all",
    },
    { "junegunn/fzf.vim" },
    { "tomtom/tlib_vim" },
    { "sheerun/vim-polyglot" },
    { "othree/yajs.vim" },
    { "marcweber/vim-addon-mw-utils" },
    { "junegunn/vim-easy-align" },
    { "morhetz/gruvbox" },
    { "rakr/vim-one" },
    { "joshdick/onedark.vim" },
    { "itchyny/lightline.vim" },
  }, {
    ui = {
      border = "rounded",
    },
  })
end

return M
