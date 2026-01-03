require('neo-tree').setup({
  close_if_last_window = true,
  enable_git_status = true,
  enable_diagnostics = true,
  window = {
    width = 30,
  },
  filesystem = {
    hijack_netrw_behavior = "disabled",
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    window = {
      position = "float",
      popup = {
        size      = { width = "60%", height = "80%" }, --% か行数/列数
        position  = "50%",        -- 画面中央（数値や table も可）
        border    = "rounded",    -- or "single", "double", …
      }
    },
    follow_current_file = true,
    use_libuv_file_watcher = true,
  },
  default_component_configs = {
    indent = {
      indent_size = 2,
      padding = 1,
    },
  },
})

vim.keymap.set('n', 'ge', ':Neotree filesystem<CR>')

require("lsp-file-operations").setup()

local lspconfig = require('lspconfig')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')


require('dressing').setup()
require('lspsaga').setup()
require('lsp_signature').setup({ hint_enable = false })
require('fidget').setup()

mason.setup()

mason_lspconfig.setup({
  ensure_installed = {
    'vtsls',
    'eslint',
  },
  automatic_installation = true,
})

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", vim.tbl_extend('force', bufopts, { desc = 'ホバードキュメントを表示' }))
  vim.keymap.set('n', 'gr', '<Cmd>Telescope lsp_references<CR>', vim.tbl_extend('force', bufopts, { desc = '参照箇所を表示' }))
  vim.keymap.set('n', 'ga', '<cmd>Lspsaga diagnostic_jump_next<CR>', vim.tbl_extend('force', bufopts, { desc = '次の診断へジャンプ' }))
  vim.keymap.set('n', 'gA', '<cmd>Lspsaga diagnostic_jump_prev<CR>', vim.tbl_extend('force', bufopts, { desc = '前の診断へジャンプ' }))
  vim.keymap.set('n', 'ma', '<cmd>Lspsaga code_action<CR>', vim.tbl_extend('force', bufopts, { desc = 'コードアクション' }))
  vim.keymap.set("n", "mr", "<cmd>Lspsaga rename<CR>", vim.tbl_extend('force', bufopts, { desc = 'シンボルをリネーム' }))
  vim.keymap.set('n', 'mf', function() require("conform").format() end, vim.tbl_extend('force', bufopts, { desc = 'コードをフォーマット' }))
  vim.keymap.set('n', 'gp', '<C-o>', vim.tbl_extend('force', bufopts, { desc = '前のジャンプ位置に戻る' }))
  vim.keymap.set("n", "gf", "<cmd>Lspsaga lsp_finder<CR>", vim.tbl_extend('force', bufopts, { desc = 'シンボルを検索' }))
  vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", vim.tbl_extend('force', bufopts, { desc = '定義へジャンプ' }))
end

local capabilities = vim.tbl_deep_extend(
  "force",
  require("cmp_nvim_lsp").default_capabilities(),
  require("lsp-file-operations").default_capabilities()
)


mason_lspconfig.setup_handlers({
  function(server_name)
    local opts = {
      capabilities = capabilities,
      on_attach = on_attach,
      flags = {
        debounce_text_changes = 150,
      },
    }

    -- vtsls
    if server_name == "vtsls" then
      opts.settings = {
        typescript = {
          updateImportsOnFileMove = { enabled = "always" },
        },
        javascript = {
          updateImportsOnFileMove = { enabled = "always" },
        },
      }
    end

    lspconfig[server_name].setup(opts)
  end,
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'typescript', 'typescriptreact',},
  callback = function()
    vim.keymap.set({ 'n' }, '<Plug>(lsp)f', function()
      vim.cmd("EslintFixAll")
      require("conform").format()
    end, { buffer = true })
  end,
})

