# Neovimプラグイン整理プラン

## 現状分析

### インストール済みプラグイン一覧（カテゴリー別）

#### 1. カラースキーム・UI
- `Shatur/neovim-ayu` - Ayuカラースキーム
- `sainnhe/gruvbox-material` - Gruvboxカラースキーム
- `nvim-lualine/lualine.nvim` - ステータスライン
- `kyazdani42/nvim-web-devicons` - アイコン表示

#### 2. ファジーファインダー
- `nvim-telescope/telescope.nvim` - ファジーファインダー（メイン）
- `nvim-telescope/telescope-file-browser.nvim` - Telescope拡張
- `nvim-lua/plenary.nvim` - Telescope依存ライブラリ

#### 3. LSP関連
- `neovim/nvim-lspconfig` - LSP基本設定
- `williamboman/mason.nvim` - LSPサーバー管理
- `williamboman/mason-lspconfig.nvim` - Mason-LSP連携
- `nvimdev/lspsaga.nvim` - LSP UI強化
- `ray-x/lsp_signature.nvim` - 関数シグネチャ表示
- `j-hui/fidget.nvim` - LSP進捗表示
- `antosha417/nvim-lsp-file-operations` - LSPファイル操作連携

#### 4. UI強化
- `stevearc/dressing.nvim` - UI改善
- `onsails/lspkind-nvim` - 補完メニューにアイコン表示

#### 5. 補完
- `hrsh7th/nvim-cmp` - 補完エンジン
- `hrsh7th/cmp-nvim-lsp` - LSP補完ソース
- `hrsh7th/cmp-buffer` - バッファ補完ソース
- `hrsh7th/cmp-path` - パス補完ソース
- `hrsh7th/cmp-cmdline` - コマンドライン補完ソース

#### 6. スニペット
- `hrsh7th/vim-vsnip` - スニペットエンジン
- `hrsh7th/cmp-vsnip` - vsnip補完連携

#### 7. ファイルエクスプローラー ⚠️ 重複あり
- `lambdalisue/fern.vim` - ファイルツリー（未使用？）
- `nvim-neo-tree/neo-tree.nvim` - ファイルツリー（**使用中**）
- `MunifTanjim/nui.nvim` - neo-tree依存UI
- `mikavilpas/yazi.nvim` - ファイルマネージャー連携

#### 8. シンタックス・パース
- `nvim-treesitter/nvim-treesitter` - シンタックスハイライト強化

#### 9. フォーマット・リント
- `stevearc/conform.nvim` - フォーマッター
- `mfussenegger/nvim-lint` - Linter

#### 10. ターミナル
- `akinsho/toggleterm.nvim` - ターミナル統合

#### 11. テキスト編集
- `kylechui/nvim-surround` - 囲み文字操作
- `numToStr/Comment.nvim` - コメント操作

#### 12. Git関連
- `lewis6991/gitsigns.nvim` - Git行表示
- `akinsho/git-conflict.nvim` - コンフリクト解決支援

#### 13. AI
- `github/copilot.vim` - GitHub Copilot

---

## 問題点

### 1. 【廃止・入れ替え推奨】メンテナンス終了系

#### 1-1. Comment.nvim（開発終了）
- **現状**: 開発終了（アーカイブ）されている
- **今どき**: Neovim 0.10以降は標準機能で `gcc` などが使える
- **代替**: プラグイン削除 or `folke/ts-comments.nvim`（Vue/React等の複雑な言語用）

#### 1-2. vim-vsnip（古い）
- **現状**: やや古いスニペットエンジン
- **今どき**: `L3MON4D3/LuaSnip` がデファクトスタンダード
- **メリット**: 拡張性が段違い

#### 1-3. nvim-web-devicons（リポジトリ移転）
- **現状**: `kyazdani42/nvim-web-devicons` は古いリポジトリ
- **今どき**: `nvim-tree/nvim-web-devicons` に移行済み
- **影響**: 中身はほぼ同じだが、メンテナンス先が変更

### 2. 【整理】機能重複系

#### 2-1. ファイルエクスプローラーの重複
- **fern.vim**: init.luaに記載、after/plugin/に設定なし → **削除推奨**
- **neo-tree.nvim**: 実際に設定・使用中（`ge`キーマップ、フローティング表示）
- **yazi.nvim**: ファイルマネージャー連携（ディレクトリ開くと起動）
- **telescope-file-browser**: fzf的なファイル検索（`sf`キーマップ）

**判定**:
- `fern.vim` は削除（neo-tree/yaziで代替可能）
- neo-tree/yazi は用途が異なるので両方残してもOK

#### 2-2. カラースキームの重複
- `neovim-ayu`と`gruvbox-material`が両方インストール
- after/plugin/colorschema.luaで使用しているのは1つのみ

**判定**: 使用していない方を削除可能

### 3. 【モダン化】Rust製・高速化への道

#### 3-1. nvim-cmp → blink.cmp（Rust製）
- **現状**: nvim-cmp + 複数のソースプラグイン（5-6個）
- **今どき**: `Saghen/blink.cmp` - Rust製で爆速
- **メリット**:
  - cmp-nvim-lsp, cmp-buffer, cmp-path, cmp-cmdline を1つに統合
  - LuaSnip も不要になる
  - 設定が劇的にシンプル
- **難易度**: 高（設定の大幅変更が必要）

#### 3-2. copilot.vim → copilot.lua
- **現状**: `github/copilot.vim` (Vim script版)
- **今どき**: `zbirenbaum/copilot.lua` (Lua版)
- **メリット**:
  - nvim-cmp/blink.cmp の候補内にCopilot提案を統合可能
  - 動作が軽快
  - Neovimとの統合性が高い

### 4. 未使用プラグインの確認が必要
- `nvim-lint`: conform.nvimを使用しているが、lintの設定ファイルが不明
- `toggleterm.nvim`: 設定ファイルが見当たらない（未設定の可能性）
- `Comment.nvim`: 設定ファイルなし（デフォルト設定 or 未使用）

---

## 整理方針

### フェーズ1: 即座に削除可能（低リスク）

#### 1-1. fern.vimの削除
```lua
-- init.lua から削除
'lambdalisue/fern.vim',  -- ← この行を削除
```
**理由**: neo-tree.nvim/yazi.nvimがあるため不要

#### 1-2. カラースキームの整理
1. `after/plugin/colorschema.lua`を確認
2. 使用していないカラースキームを削除

#### 1-3. Comment.nvimの削除（オプション）
```lua
-- init.lua から削除
'numToStr/Comment.nvim',  -- ← Neovim 0.10+ なら不要
```
**条件**: Neovim 0.10以降を使用している場合
**代替**: 標準機能（`gcc`など）、または `folke/ts-comments.nvim`

### フェーズ2: 簡単な入れ替え（中リスク）

#### 2-1. nvim-web-deviconsのリポジトリ変更
```lua
-- 変更前
'kyazdani42/nvim-web-devicons',
-- 変更後
'nvim-tree/nvim-web-devicons',
```
**影響**: ほぼなし（中身は同じ）

#### 2-2. vim-vsnip → LuaSnip
```lua
-- 削除
'hrsh7th/vim-vsnip',
'hrsh7th/cmp-vsnip',

-- 追加
'L3MON4D3/LuaSnip',
'saadparwaiz1/cmp_luasnip',
```
**影響**: 設定ファイル変更必要（after/plugin/vsnip.lua → luasnip.lua）

#### 2-3. copilot.vim → copilot.lua
```lua
-- 削除
'github/copilot.vim',

-- 追加
'zbirenbaum/copilot.lua',
```
**影響**: 設定ファイル変更必要、cmpとの統合も可能

### フェーズ3: 大規模変更（高リスク・高リターン）

#### 3-1. nvim-cmp → blink.cmp（Rust製）
```lua
-- 削除（5-6個）
'hrsh7th/nvim-cmp',
'hrsh7th/cmp-nvim-lsp',
'hrsh7th/cmp-buffer',
'hrsh7th/cmp-path',
'hrsh7th/cmp-cmdline',
'onsails/lspkind-nvim',

-- 追加（1個）
'Saghen/blink.cmp',
```
**メリット**:
- Rust製で爆速
- 設定が劇的にシンプル
- プラグイン数削減

**デメリット**:
- 設定の大幅変更が必要
- 学習コストあり

### フェーズ4: 未使用プラグインの確認と整理

#### 4-1. 設定ファイルの確認
以下のプラグインに設定ファイルがあるか確認：
- `mfussenegger/nvim-lint` → after/plugin/lint.lua？
- `akinsho/toggleterm.nvim` → after/plugin/toggleterm.lua？
- `akinsho/git-conflict.nvim` → after/plugin/git-conflict.lua？

#### 4-2. 未設定プラグインの対応
- デフォルト設定で動作しているなら維持
- 未使用なら削除

### フェーズ5: 最適化（オプション）

#### 5-1. lazy.nvimの遅延読み込み設定
```lua
-- 例: Telescopeの遅延読み込み
{
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  keys = {
    { ';f', desc = 'ファイルを検索' },
    { ';r', desc = 'テキストをGrepで検索' },
  },
},
```

#### 5-2. neo-tree設定の重複解消
- lsp.lua と neo-tree.lua で設定が重複
- どちらか一方に統合する

### フェーズ6: ドキュメント整備

#### 6-1. プラグイン一覧ドキュメントの作成
- `packages/nvim/README.md` にプラグイン一覧と役割を記載
- キーマップ一覧の整理

#### 6-2. 設定ファイルのコメント充実
- 各after/plugin/*.luaに用途と主要設定の説明を追加

---

## 実行チェックリスト

### □ フェーズ1: 即座に削除可能（低リスク）⭐️ 推奨
- [ ] Neovimバージョン確認（`nvim --version`）
- [ ] after/plugin/colorschema.lua を確認
- [ ] 未使用のカラースキームを特定
- [ ] init.luaから `fern.vim` を削除
- [ ] init.luaから未使用カラースキームを削除
- [ ] init.luaから `Comment.nvim` を削除（0.10+の場合）
- [ ] `:Lazy clean` でプラグインクリーンアップ
- [ ] Neovimを再起動して動作確認

### □ フェーズ2: 簡単な入れ替え（中リスク）
- [ ] `kyazdani42/nvim-web-devicons` → `nvim-tree/nvim-web-devicons` に変更
- [ ] `:Lazy sync` で同期
- [ ] 動作確認

**vim-vsnip → LuaSnip（オプション）**
- [ ] after/plugin/vsnip.lua を確認
- [ ] LuaSnip の設定を作成
- [ ] init.lua でプラグイン入れ替え
- [ ] `:Lazy sync` で同期
- [ ] スニペット動作確認

**copilot.vim → copilot.lua（オプション）**
- [ ] copilot.lua の設定を作成
- [ ] init.lua でプラグイン入れ替え
- [ ] `:Lazy sync` で同期
- [ ] Copilot 動作確認
- [ ] （任意）cmp統合設定

### □ フェーズ3: 大規模変更（高リスク・高リターン）⚠️ 慎重に
**nvim-cmp → blink.cmp（Rust製）**
- [ ] blink.cmp のドキュメント確認
- [ ] 設定ファイル作成（after/plugin/blink-cmp.lua）
- [ ] init.lua で nvim-cmp 系すべて削除、blink.cmp 追加
- [ ] LSP設定の調整（capabilities等）
- [ ] `:Lazy sync` で同期
- [ ] 補完動作の徹底確認
- [ ] 問題があれば即座にロールバック

### □ フェーズ4: 未使用プラグイン確認
- [ ] nvim-lint の設定ファイル確認
- [ ] toggleterm.nvim の設定ファイル確認
- [ ] git-conflict.nvim の設定ファイル確認
- [ ] 各プラグインの使用状況を判定
- [ ] 未使用プラグインを削除

### □ フェーズ5: 最適化（オプション）
- [ ] neo-tree 設定の重複解消（lsp.lua から削除）
- [ ] lazy.nvim 遅延読み込み設定を追加
- [ ] プラグイン設定のモジュール化を検討

### □ フェーズ6: ドキュメント整備
- [ ] packages/nvim/README.md を作成
- [ ] キーマップ一覧をドキュメント化
- [ ] 各設定ファイルにコメント追加

---

## 次のアクション - 推奨順序

### 🚀 今すぐ実行推奨: フェーズ1（低リスク・即効性）
1. `fern.vim` を削除（完全に未使用）
2. カラースキーム整理（使用していない方を削除）
3. `Comment.nvim` を削除（Neovim 0.10+の場合）

**効果**: プラグイン数削減、起動速度向上

### 🔧 次に検討: フェーズ2（中リスク・効果大）
1. `nvim-web-devicons` のリポジトリ変更（ほぼノーリスク）
2. `copilot.vim` → `copilot.lua` に変更
   - cmp統合で補完体験向上

**効果**: モダン化、機能向上

### 🎯 余裕があれば: フェーズ2続き
3. `vim-vsnip` → `LuaSnip` に変更
   - より高機能なスニペット

### ⚡ チャレンジ: フェーズ3（高リスク・高リターン）
- `nvim-cmp` → `blink.cmp` (Rust製)
  - **メリット**: プラグイン5-6個削減、爆速補完
  - **デメリット**: 設定変更コストが大きい
  - **推奨**: 時間があるときに別ブランチで試す

### 🧹 定期的に: フェーズ4-6
- 未使用プラグインの確認
- 設定の最適化
- ドキュメント整備

---

## Geminiの推奨プラン（参考）

1. **まずは軽く**: `Comment.nvim` と `fern.vim` を削除
2. **次にモダン化**: `copilot.lua` に変更
3. **チャレンジ**: `blink.cmp` で補完を統一

---

## 注意事項

### 必須の事前準備
- ✅ プラグイン削除・変更前に **必ずgitコミットを作成**
- ✅ 変更後は `:Lazy clean` でキャッシュクリア
- ✅ 動作確認を徹底的に実施
- ✅ 問題があれば即座にgitで元に戻す

### バージョン確認
- Neovim 0.10以降かを確認: `nvim --version`
- 0.10未満の場合、Comment.nvim削除は非推奨

### ブランチ戦略
- 大規模変更（blink.cmpなど）は別ブランチで試す
- 動作確認後にマージする
