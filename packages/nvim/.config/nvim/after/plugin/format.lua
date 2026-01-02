print('format')
local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "biome", "prettier", stop_after_first = true },
    typescript = { "biome", "prettier", stop_after_first = true },
    typescriptreact = { "biome", "prettier", stop_after_first = true },
    javascriptreact = { "biome", "prettier", stop_after_first = true },
    json = { "biome" },
  },
  formatters = {
    prettier = {
      prepend_args = { "--tab-width", "2" },
    },
  },
  format_on_save = {
    timeout_ms   = 500,
    lsp_fallback = true,
    lsp_format = "fallback",
  },
})
