local status, blink = pcall(require, "blink.cmp")
if (not status) then return end

blink.setup({
  -- キーマップ設定
  keymap = {
    preset = 'default',
    ['<Tab>'] = { 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'fallback' },
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

  -- ソース設定（全て内蔵）
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
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
    proximity = {
      enabled = true,
    },
  },

  -- シグネチャヘルプ
  signature = {
    enabled = true,
  },
})
