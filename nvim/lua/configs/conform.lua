local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    vue = { "prettier" },

    css = { "prettier" },
    scss = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },

    sh = { "shfmt" },
    bash = { "shfmt" },

    terraform = { "terraform_fmt" },
    hcl = { "terraform_fmt" },
  },

  -- Fall back to the LSP formatter for filetypes with no formatter above.
  default_format_opts = { lsp_format = "fallback" },

  formatters = {
    prettier = {
      -- Run prettier from the project root so it picks up that project's
      -- .prettierrc. Without this, mason's prettier resolves config (and
      -- plugins) relative to wherever nvim happens to be, so formatting can
      -- silently differ from CI.
      cwd = require("conform.util").root_file {
        ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.cjs",
        ".prettierrc.yaml", ".prettierrc.yml", "prettier.config.js",
        "prettier.config.cjs", "package.json",
      },
    },
  },

  -- format_on_save is deliberately OFF. Insert-mode <Esc> is mapped to
  -- save_if_real() (mappings.lua), so the buffer is written constantly —
  -- formatting on top of that would reformat under the cursor mid-thought.
  -- <F6> and <leader>fm format on demand instead.
}

return options
