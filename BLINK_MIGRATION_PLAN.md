# blink.cmp 移行プラン（フェーズ3）

## 参考資料
- [公式ドキュメント](https://cmp.saghen.dev/)
- [インストールガイド](https://cmp.saghen.dev/installation)
- [GitHub リポジトリ](https://github.com/saghen/blink.cmp)
- [キーマップ設定](https://cmp.saghen.dev/configuration/keymap)
- [ソース設定](https://cmp.saghen.dev/configuration/sources)

## 概要

**目的**: nvim-cmp から blink.cmp（Rust製の高速補完プラグイン）に移行

**メリット**:
- 🚀 **爆速**: Rust製で0.5-4ms、nvim-cmpの60ms debounceと比較して劇的に高速
- 📦 **統合**: 5-6個のプラグインを1つに統合
- 🎯 **シンプル**: 設定が劇的にシンプル
- ✨ **内蔵**: LSP、buffer、path、snippetsが全て内蔵

**デメリット**:
- ⚠️ 設定の大幅変更が必要
- 📚 学習コスト

---

## 現在の構成

### 削除するプラグイン（6個）
```lua
'hrsh7th/nvim-cmp',              -- 補完エンジン本体
'hrsh7th/cmp-nvim-lsp',          -- LSPソース
'hrsh7th/cmp-buffer',            -- バッファソース
'hrsh7th/cmp-path',              -- パスソース
'hrsh7th/cmp-cmdline',           -- コマンドラインソース
'onsails/lspkind-nvim',          -- アイコン表示
'L3MON4D3/LuaSnip',              -- スニペットエンジン
'saadparwaiz1/cmp_luasnip',      -- LuaSnip統合
```

### 追加するプラグイン（1個）
```lua
'saghen/blink.cmp',              -- これ1つで全て置き換え
```

### 保持するプラグイン
```lua
'zbirenbaum/copilot.lua',        -- Copilotは継続使用
```

---

## 移行手順

### ステップ1: バックアップ作成
```bash
# 現在の状態をコミット（既に完了）
git add -A
git commit -m "checkpoint: blink.cmp移行前のバックアップ"
```

### ステップ2: init.lua の変更

**削除**:
```lua
'hrsh7th/nvim-cmp',
'hrsh7th/cmp-nvim-lsp',
'hrsh7th/cmp-buffer',
'hrsh7th/cmp-path',
'hrsh7th/cmp-cmdline',
'onsails/lspkind-nvim',
'L3MON4D3/LuaSnip',
'saadparwaiz1/cmp_luasnip',
```

**追加**:
```lua
{
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',  -- スニペットコレクション
  },
  version = '1.*',
  build = 'cargo build --release',  -- Rustビルド
},
```

### ステップ3: blink.cmp 設定ファイル作成

**新規作成**: `after/plugin/blink-cmp.lua`

```lua
local status, blink = pcall(require, "blink.cmp")
if (not status) then return end

blink.setup({
  -- キーマップ設定
  keymap = {
    preset = 'default',  -- C-y: accept, C-space: toggle, C-n/C-p: select
    ['<Tab>'] = { 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<C-space>'] = { 'show', 'hide' },
    ['<C-e>'] = { 'hide' },
    ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
  },

  -- 外観設定
  appearance = {
    use_nvim_cmp_as_default = true,  -- nvim-cmp風の見た目
    nerd_font_variant = 'mono',
  },

  -- ソース設定（全て内蔵）
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    -- cmdlineは自動で有効化される
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

  -- スニペット設定（内蔵エンジン）
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
    implementation = "prefer_rust_with_warning",
    prebuilt_binaries = {
      download = true,
      force_version = nil,
    },
  },
})
```

### ステップ4: LSP設定の更新

**変更**: `after/plugin/lsp.lua`

**変更前**:
```lua
local capabilities = vim.tbl_deep_extend(
  "force",
  require("cmp_nvim_lsp").default_capabilities(),
  require("lsp-file-operations").default_capabilities()
)
```

**変更後**:
```lua
local capabilities = require('blink.cmp').get_lsp_capabilities()
```

### ステップ5: 削除する設定ファイル

```bash
rm after/plugin/nvim-cmp.lua
rm after/plugin/luasnip.lua
```

### ステップ6: Copilot統合（オプション）

blink.cmp は nvim-cmp ソースの互換レイヤー（blink.compat）を提供していますが、
現時点では copilot.lua を独立して使用することを推奨します。

**copilot.lua の設定調整**:
```lua
-- after/plugin/copilot.lua
-- キーマップを調整（blink.cmpと競合しないように）
suggestion = {
  keymap = {
    accept = "<M-l>",      -- Alt+l に変更（Tabは blink.cmp が使用）
    accept_word = "<M-w>",
    accept_line = "<M-j>",
    next = "<M-]>",
    prev = "<M-[>",
    dismiss = "<C-]>",
  },
},
```

---

## 動作確認チェックリスト

### ✅ 基本機能
- [ ] Neovim起動時にエラーが出ない
- [ ] `:Lazy sync` でプラグインが正しくインストールされる
- [ ] Rustバイナリが正しくビルドされる

### ✅ LSP補完
- [ ] TypeScript/JavaScriptファイルで補完が表示される
- [ ] 補完候補にLSPのシンボルが表示される
- [ ] `<Tab>` で補完候補を選択できる
- [ ] `<CR>` で補完を確定できる

### ✅ スニペット
- [ ] スニペットが展開できる
- [ ] スニペット内でジャンプできる

### ✅ その他のソース
- [ ] バッファ内の単語が補完候補に表示される
- [ ] パス補完が動作する

### ✅ Copilot
- [ ] Copilotの提案が表示される
- [ ] `<M-l>` で提案を受け入れられる

---

## トラブルシューティング

### エラー: Rustバイナリのビルドに失敗
```bash
# Rustがインストールされているか確認
rustc --version

# インストールされていない場合
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# lazy.nvimでリビルド
:Lazy build blink.cmp
```

### エラー: 補完が表示されない
```lua
-- LSP capabilities が正しく設定されているか確認
:lua print(vim.inspect(require('blink.cmp').get_lsp_capabilities()))
```

### エラー: キーマップが動作しない
```lua
-- 現在のキーマップを確認
:nmap <Tab>
:imap <Tab>

-- blink.cmpのキーマップをリセット
:lua require('blink.cmp').setup({ keymap = { preset = 'default' } })
```

---

## ロールバック手順

問題が発生した場合、即座に元に戻せます：

```bash
# 前のコミットに戻る
git reset --hard HEAD~1

# Neovimを再起動
nvim

# プラグインをクリーンアップ
:Lazy clean
:Lazy sync
```

---

## 期待される効果

### パフォーマンス
- ⚡ 補完表示速度: **60ms → 0.5-4ms**（約15-120倍高速）
- 📉 プラグイン数: **8個 → 1個**（7個削減）
- 💾 設定ファイル: **2ファイル → 1ファイル**

### 開発体験
- ✨ よりスムーズなタイピング体験
- 🎯 正確なファジーマッチ
- 📚 シンプルな設定

---

## 次のステップ

1. ✅ このプランを確認
2. ⚠️ バックアップを作成（重要！）
3. 🚀 移行を実行
4. ✅ 動作確認
5. 🎉 完了！

---

## 注意事項

- **慎重に**: この移行は大規模な変更です
- **テスト**: 各ステップで動作確認を行ってください
- **バックアップ**: いつでもロールバックできるようにしておいてください
- **時間**: 30分〜1時間程度かかる可能性があります
