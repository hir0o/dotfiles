local cargo_build = nil
if vim.fn.executable('cargo') == 1 then
  cargo_build = 'cargo build --release'
end

return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'saghen/blink.compat',
  },
  version = '1.*',
  build = cargo_build,
  event = { 'InsertEnter', 'CmdlineEnter' },
  config = function()
    require("blink.cmp").setup({
      -- キーマップ設定
      keymap = {
        preset = 'default',
        ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
        -- Ctrl+n/pでも補完選択可能
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-space>'] = { 'show', 'hide' },
        ['<C-e>'] = { 'hide' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      },

      -- 外観設定（nvim-cmp風の見た目）
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },

      -- ソース設定
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'avante_commands', 'avante_mentions', 'avante_files' },
        providers = {
          avante_commands = {
            name = "avante_commands",
            module = "blink.compat.source",
            score_offset = 90,
            opts = {},
          },
          avante_files = {
            name = "avante_files",
            module = "blink.compat.source",
            score_offset = 100,
            opts = {},
          },
          avante_mentions = {
            name = "avante_mentions",
            module = "blink.compat.source",
            score_offset = 1000,
            opts = {},
          },
        },
      },

      -- 補完設定
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        },
        menu = {
          draw = {
            columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
          },
        },
      },

      -- スニペット設定（Neovim 0.10+ の内蔵スニペットエンジン）
      snippets = {
        expand = function(snippet) vim.snippet.expand(snippet) end,
        active = function(filter)
          if filter and filter.direction then
            return vim.snippet.active({ direction = filter.direction })
          end
          return vim.snippet.active()
        end,
        jump = function(direction) vim.snippet.jump(direction) end,
      },

      -- ファジーマッチ（Rust実装を優先）
      fuzzy = {
        frecency = {
          enabled = true,
        },
        use_proximity = true,
      },

      -- シグネチャヘルプ
      signature = {
        enabled = true,
      },
    })
  end,
}
