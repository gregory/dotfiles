return {
  defaults = { lazy = true },
  install = { colorscheme = { "nvchad" } },

  ui = {
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  performance = {
    rtp = {
      -- Only names that actually exist in $VIMRUNTIME/plugin/ of this Neovim.
      -- The previous list had 25 entries, ~16 of which targeted nothing
      -- (2html_plugin, getscript, getscriptPlugin, logipat, rrhelper, vimball,
      -- vimballPlugin, syntax, synmenu, optwin, compiler, bugreport, ftplugin,
      -- netrw, netrwSettings, netrwFileHandlers) — harmless, but they hid the
      -- one that was MISSING and actually costs something.
      disabled_plugins = {
        "gzip",
        "matchit",
        -- matchparen reparses and calls searchpairpos() with a timeout on every
        -- CursorMoved / CursorMovedI. It is the single biggest per-keystroke
        -- builtin cost, and options.lua already sets showmatch = false, i.e.
        -- this behaviour was not wanted anyway.
        "matchparen",
        "netrwPlugin",
        "rplugin",
        "spellfile_plugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        -- NOT disabled on purpose:
        --   editorconfig -> editorconfig-vim was removed in favour of this
        --   man          -> :Man is genuinely useful
        --   osc52        -> clipboard over SSH
      },
    },
  },
}
