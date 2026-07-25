-- LSP. NvChad's defaults() already uses the modern vim.lsp.config /
-- vim.lsp.enable API and installs the on_attach keymaps, so there is nothing
-- deprecated to work around here.
require("nvchad.configs.lspconfig").defaults()

-- @vue/language-server is needed in two places: as vue_ls's own server, and as
-- a tsserver plugin inside vtsls. Vue 3 "hybrid mode" needs BOTH halves — with
-- only vue_ls you get no TypeScript inside .vue files.
local vue_ls_path = vim.fn.stdpath "data"
  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

vim.lsp.config("vtsls", {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = "@vue/typescript-plugin",
            location = vue_ls_path,
            languages = { "vue" },
            configNamespace = "typescript",
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
    },
  },
  filetypes = {
    "javascript", "javascriptreact", "javascript.jsx",
    "typescript", "typescriptreact", "typescript.tsx",
    "vue",
  },
})

vim.lsp.config("yamlls", {
  -- Otherwise it reorders your keys on format, which is never what you meant.
  settings = { yaml = { keyOrdering = false } },
})

local servers = {
  "vtsls",
  "vue_ls",
  "eslint",
  "jsonls",
  "html",
  "cssls",
  "yamlls",
  "bashls",
  -- lua_ls is already enabled by NvChad's defaults()
}

-- One pcall per server, deliberately. vim.lsp.enable{list} validates every name
-- BEFORE enabling any of them ("abort with no side-effects if there is one"),
-- so a single missing lsp/<name>.lua leaves you with ZERO servers rather than
-- the rest — an easy state to reach after a partial :MasonInstallAll, and a
-- silent one.
for _, server in ipairs(servers) do
  local ok, err = pcall(vim.lsp.enable, server)
  if not ok then
    vim.notify(("lsp: could not enable %s: %s"):format(server, err), vim.log.levels.WARN)
  end
end

-- Warn loudly if the Vue plugin path is wrong: the symptom otherwise is just
-- "TypeScript quietly does not work inside .vue files".
if vim.fn.isdirectory(vue_ls_path) == 0 then
  vim.notify(
    "lsp: @vue/language-server not found at "
      .. vue_ls_path
      .. " — run :MasonInstall vue-language-server (TS in .vue files will not work)",
    vim.log.levels.WARN
  )
end
