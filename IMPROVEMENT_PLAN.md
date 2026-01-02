# Dotfiles 改善計画書

**作成日**: 2025-12-31
**対象リポジトリ**: hir0o/dotfiles
**目的**: VSCode/Cursor設定の修正とGNU Stowへの移行による保守性向上

---

## 📊 現状分析

### 検出された問題点

| 優先度 | 問題 | 影響 | 対象ファイル |
|--------|------|------|-------------|
| 🔴 Critical | VSCodeパスの誤字 (`C/User` → `Code/User`) | VSCode設定が完全に壊れている | `scripts/setup.zsh:26` |
| 🔴 Critical | Cursor設定リンクが機能していない | Cursor設定が反映されない | `scripts/setup.zsh:30` |
| 🟡 High | 不要な setup.ts が存在 | メンテナンス負荷、混乱を招く | `scripts/setup.ts` |
| 🟡 Medium | シンボリックリンク管理の複雑さ | メンテナンス・デバッグが困難 | セットアップスクリプト全体 |

### 技術スタック
- **パッケージマネージャー**: Homebrew
- **シェル**: Zsh (Powerlevel10k + Sheldon)
- **エディタ**: VSCode, Cursor (設定共有)
- **バージョン管理**: mise (旧mise-en-place)
- **リンク管理**: カスタムスクリプト (移行予定: GNU Stow)

---

## 🎯 短期改善計画（即時実施）

### 目標
- VSCode/Cursor設定のシンボリックリンクを正常に動作させる
- セットアップスクリプトを `setup.zsh` 一本に統一し、シンプル化する

### 作業内容

#### 1. `scripts/setup.zsh` の修正

**修正箇所 A**: 26-27行目 - VSCodeパスの誤字修正

```diff
- VSCODE_PATH="$HOME/Library/Application\ Support/C/User"
- ln -sfv  "$XDG_CONFIG_HOME/vscode/"* $VSCODE_PATH
+ VSCODE_PATH="$HOME/Library/Application Support/Code/User"
+ ln -sfv "$XDG_CONFIG_HOME/vscode/"* "$VSCODE_PATH"
```

**変更点**:
- `C/User` → `Code/User` に修正（誤字修正）
- `$VSCODE_PATH` をダブルクォートで囲む（パスにスペースがあるため）

**修正箇所 B**: 30行目 - Cursorのパスも引用符で囲む

```diff
- ln -sfv "$XDG_CONFIG_HOME/vscode/"* "$HOME/Library/Application Support/Cursor/User"
+ CURSOR_PATH="$HOME/Library/Application Support/Cursor/User"
+ ln -sfv "$XDG_CONFIG_HOME/vscode/"* "$CURSOR_PATH"
```

**変更点**:
- 可読性向上のため変数化
- 既にCursor設定は有効なので、コード整理のみ

#### 2. `scripts/setup.ts` の削除

**理由**:
- ✅ **依存削減**: Deno が不要になる（macOSはzsh標準装備）
- ✅ **シンプル化**: メンテナンスするスクリプトが1つだけ
- ✅ **root権限不要**: setup.ts は root を要求していたが不要
- ✅ **GNU Stow移行を見据えて**: 中期改善で `setup-stow.sh` を作るため、複雑なロジックは不要

**削除するファイル**:
```bash
rm scripts/setup.ts
```

#### 3. `install.bash` の更新

**修正箇所**: setup.zsh の呼び出し部分

```diff
  export REPO_DIR="$INSTALL_DIR"
  /bin/zsh "$INSTALL_DIR/scripts/setup.zsh"
```

変更なし（既に setup.zsh を呼んでいるのでOK）

#### 4. `CLAUDE.md` の更新

**修正箇所**: setup.ts への言及を削除

```diff
  ### Initial Setup
  ```bash
  # Clone and run the installation script
  sh -c "`curl -fsSL https://raw.githubusercontent.com/hir0o/dotfiles/master/install.bash`"
-
- # Or use the interactive Deno TypeScript setup (requires root)
- sudo deno run -A scripts/setup.ts
  ```
```

```diff
  ### Directory Structure
  - `config/` - All tool configurations following XDG Base Directory specification
- - `scripts/` - Setup scripts (both Zsh and Deno TypeScript versions)
+ - `scripts/` - Setup scripts for initial environment setup
  - Configurations are organized by tool name under `config/`
```

```diff
  ## Important Notes

  1. The setup scripts create symbolic links from this repository to system locations - avoid editing files directly in system locations
  2. VSCode settings are linked to `~/Library/Application Support/Code/User/`
- 3. The Deno setup script (`scripts/setup.ts`) requires root access and is interactive
- 4. Git configuration includes many fzf-based interactive commands that require fzf to be installed
- 5. Many shell aliases depend on tools installed via Homebrew - ensure Brewfile is installed first
+ 3. Git configuration includes many fzf-based interactive commands that require fzf to be installed
+ 4. Many shell aliases depend on tools installed via Homebrew - ensure Brewfile is installed first
```

### 実施手順

```bash
# 1. バックアップ作成
cd ~/ghq/github.com/hir0o/dotfiles
git checkout -b fix/vscode-cursor-links

# 2. setup.zsh を修正
#    - 26行目: C/User → Code/User
#    - 27行目: $VSCODE_PATH をクォートで囲む
#    - 30行目: CURSOR_PATH 変数化

# 3. setup.ts を削除
rm scripts/setup.ts

# 4. CLAUDE.md を修正
#    - 16-17行目: setup.ts への言及を削除
#    - 34行目: "both Zsh and Deno TypeScript versions" を修正
#    - 80行目: setup.ts の説明を削除、番号を詰める

# 5. 既存のシンボリックリンクを削除
rm -f ~/Library/Application\ Support/Code/User/{settings.json,keybindings.json}
rm -f ~/Library/Application\ Support/Cursor/User/{settings.json,keybindings.json}
rm -rf ~/Library/Application\ Support/Code/User/snippets
rm -rf ~/Library/Application\ Support/Cursor/User/snippets

# 6. セットアップスクリプトを再実行
/bin/zsh scripts/setup.zsh

# 7. 動作確認
ls -la ~/Library/Application\ Support/Code/User/
ls -la ~/Library/Application\ Support/Cursor/User/

# 8. VSCode/Cursorを起動して設定が反映されているか確認

# 9. 問題なければコミット
git add .
git commit -m "fix: VSCode/Cursor設定の修正とsetup.ts削除"
```

### 期待される結果

- ✅ VSCode設定ファイルが正しくリンクされる
- ✅ Cursor設定ファイルが正しくリンクされる
- ✅ 両エディタで同じ設定が共有される
- ✅ snippets ディレクトリも正しくリンクされる
- ✅ セットアップスクリプトが setup.zsh 一本に統一される
- ✅ Deno 依存が不要になる

### リスク対策

| リスク | 対策 |
|--------|------|
| 既存設定が失われる | Git管理 + ブランチ作成でロールバック可能 |
| リンク先ディレクトリが存在しない | 事前に VSCode/Cursor を起動してディレクトリ作成 |
| setup.ts 削除後に戻したくなる | Git履歴に残っているので `git checkout` で復元可能 |

---

## 🚀 中期改善計画（GNU Stow移行）

### 目標
シンボリックリンク管理を GNU Stow に移行し、保守性を向上させる

### GNU Stow とは

**公式**: https://www.gnu.org/software/stow/

**特徴**:
- シンボリックリンク管理専用ツール（"symlink farm manager"）
- パッケージ単位でリンクを管理
- `stow` でリンク作成、`stow -D` でリンク削除
- 依存が少なく、シンプル
- リバーシブル（元に戻せる）

**vs カスタムスクリプト**:
| 項目 | カスタムスクリプト | GNU Stow |
|------|-------------------|----------|
| 学習コスト | 低（既存実装を理解済み） | 低（コマンド数が少ない） |
| 保守性 | 低（スクリプト修正が必要） | 高（標準ツール） |
| デバッグ | 難（カスタムロジック） | 容易（`-n` でdry-run可能） |
| テンプレート機能 | なし | なし |
| 暗号化 | なし | なし（別途GPG等） |

### 移行前の準備

#### 1. GNU Stow のインストール

```bash
# Brewfile に追加
echo 'brew "stow"' >> config/homebrew/Brewfile
brew install stow
```

#### 2. ディレクトリ構造の再設計

**現在の構造**:
```
dotfiles/
├── config/
│   ├── nvim/
│   ├── vscode/
│   ├── zsh/
│   └── ...
└── scripts/
```

**Stow推奨構造**:
```
dotfiles/
├── nvim/          # パッケージ名
│   └── .config/
│       └── nvim/
│           ├── init.lua
│           └── ...
├── vscode/
│   └── Library/
│       └── Application Support/
│           └── Code/
│               └── User/
│                   ├── settings.json
│                   └── keybindings.json
├── zsh/
│   ├── .config/
│   │   └── zsh/
│   │       ├── .zshrc
│   │       └── ...
│   └── .zshenv
└── README.md
```

**設計のポイント**:
- 各ツールを独立したパッケージとして管理
- パッケージ内は実際のホームディレクトリ構造を再現
- `stow -t ~ <package>` でリンク作成

#### 3. 移行計画の詳細ステップ

##### Phase 1: 環境準備（所要時間: 30分）

```bash
# 1. 作業ブランチ作成
git checkout -b feature/migrate-to-stow

# 2. GNU Stow インストール
brew install stow

# 3. 現在のシンボリックリンクをバックアップリスト化
find ~ -type l -ls | grep ".config\|Library" > ~/dotfiles-links-backup.txt
```

##### Phase 2: ディレクトリ構造の移行（所要時間: 1-2時間）

```bash
cd ~/ghq/github.com/hir0o/dotfiles

# 新しいStow形式のディレクトリを作成
mkdir -p packages/{nvim,vscode,cursor,zsh,git}

# 各パッケージのディレクトリ構造を作成
# nvim の例:
mkdir -p packages/nvim/.config
mv config/nvim packages/nvim/.config/

# vscode の例（特殊パス）:
mkdir -p "packages/vscode/Library/Application Support/Code/User"
mv config/vscode/* "packages/vscode/Library/Application Support/Code/User/"

# cursor は vscode 設定を参照（シンボリックリンクまたは同じファイル）
mkdir -p "packages/cursor/Library/Application Support/Cursor/User"
ln -s ../../../vscode/Library/Application\ Support/Code/User/* \
      "packages/cursor/Library/Application Support/Cursor/User/"

# zsh の例:
mkdir -p packages/zsh/.config
mv config/zsh packages/zsh/.config/
mv config/zsh/.zshenv packages/zsh/
```

##### Phase 3: Stow によるリンク作成（所要時間: 15分）

```bash
# Dry-run でテスト（実際にはリンクを作成しない）
cd ~/ghq/github.com/hir0o/dotfiles
stow -n -v -t ~ packages/nvim
stow -n -v -t ~ packages/vscode
stow -n -v -t ~ packages/zsh

# 問題なければ実際にリンク作成
stow -v -t ~ packages/nvim
stow -v -t ~ packages/vscode
stow -v -t ~ packages/cursor
stow -v -t ~ packages/zsh
stow -v -t ~ packages/git
```

##### Phase 4: セットアップスクリプトの更新（所要時間: 30分）

**新しい `scripts/setup-stow.sh`**:

```bash
#!/bin/bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/ghq/github.com/hir0o/dotfiles}"
STOW_DIR="$REPO_DIR/packages"

# Stowがインストールされているか確認
if ! command -v stow &> /dev/null; then
    echo "Error: GNU Stow is not installed."
    echo "Run: brew install stow"
    exit 1
fi

# リンクを作成するパッケージのリスト
PACKAGES=(
    "nvim"
    "vscode"
    "cursor"
    "zsh"
    "git"
    "tmux"
    "alacritty"
)

echo "Setting up dotfiles with GNU Stow..."

for package in "${PACKAGES[@]}"; do
    if [ -d "$STOW_DIR/$package" ]; then
        echo "Stowing $package..."
        stow -v -d "$STOW_DIR" -t "$HOME" "$package"
    else
        echo "Warning: Package $package not found, skipping..."
    fi
done

echo "Done! All packages have been stowed."
```

##### Phase 5: 動作確認とクリーンアップ（所要時間: 30分）

```bash
# 1. 各ツールの設定が読み込まれるか確認
nvim --version
code --version
zsh -c 'echo $ZDOTDIR'

# 2. シンボリックリンクの確認
ls -la ~/.config/nvim
ls -la ~/Library/Application\ Support/Code/User

# 3. 古いセットアップスクリプトを削除またはアーカイブ
mkdir -p archive
mv scripts/setup.zsh archive/
mv scripts/setup.ts archive/

# 4. READMEの更新
# CLAUDE.md の Setup Commands セクションを更新
```

### 移行後のディレクトリ構造

```
dotfiles/
├── packages/        # Stow パッケージディレクトリ
│   ├── nvim/
│   │   └── .config/
│   │       └── nvim/
│   ├── vscode/
│   │   └── Library/
│   │       └── Application Support/
│   │           └── Code/
│   │               └── User/
│   ├── cursor/           # vscode設定へのリンク
│   ├── zsh/
│   │   ├── .config/
│   │   │   └── zsh/
│   │   └── .zshenv
│   ├── git/
│   │   └── .config/
│   │       └── git/
│   └── ...
├── scripts/
│   ├── setup-stow.sh     # 新メインスクリプト
│   └── archive/          # 旧スクリプト
│       ├── setup.zsh
│       └── setup.ts
├── config/               # 削除またはアーカイブ
├── CLAUDE.md
├── IMPROVEMENT_PLAN.md   # このファイル
└── README.md
```

### 新しいセットアップフロー

**初回セットアップ**:
```bash
# 1. リポジトリのクローン
git clone https://github.com/hir0o/dotfiles.git ~/ghq/github.com/hir0o/dotfiles
cd ~/ghq/github.com/hir0o/dotfiles

# 2. Homebrewのインストール（必要に応じて）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Brewfileからパッケージインストール
brew bundle install --file config/homebrew/Brewfile

# 4. Stowでシンボリックリンク作成
bash scripts/setup-stow.sh
```

**パッケージの追加/削除**:
```bash
# 追加
stow -v -t ~ packages/新パッケージ

# 削除
stow -D -v -t ~ packages/パッケージ名
```

**設定の更新**:
```bash
# 通常通りdotfilesリポジトリ内のファイルを編集
nvim ~/ghq/github.com/hir0o/dotfiles/packages/nvim/.config/nvim/init.lua

# 変更をコミット
cd ~/ghq/github.com/hir0o/dotfiles
git add .
git commit -m "update: nvim config"
git push
```

### メリット

1. **保守性向上**
   - 標準ツールの使用でドキュメントが豊富
   - カスタムスクリプトのメンテナンス不要

2. **デバッグの容易さ**
   - `stow -n` でdry-run可能
   - エラーメッセージが明確

3. **可逆性**
   - `stow -D` で簡単にリンク削除
   - 元の状態に戻すのが容易

4. **パッケージ単位の管理**
   - 必要なパッケージだけリンク
   - 環境ごとに異なるパッケージセットを適用可能

### デメリットと対策

| デメリット | 対策 |
|-----------|------|
| ディレクトリ構造が深くなる | エイリアスや変数で短縮 |
| VSCode/Cursorの特殊パス | ドキュメントで明記 |
| 移行作業の手間 | 段階的移行（パッケージごと） |
| チーム共有時の学習コスト | README/CLAUDE.mdに詳細記載 |

### ロールバック手順

移行後に問題が発生した場合:

```bash
# 1. Stowで作成したリンクを削除
cd ~/ghq/github.com/hir0o/dotfiles
stow -D -v -t ~ packages/*

# 2. 旧ブランチに戻る
git checkout main

# 3. 旧セットアップスクリプトを実行
bash install.bash
```

---

## 📅 実施スケジュール

### 短期改善（即時）
- **所要時間**: 1時間
- **実施タイミング**: この計画書承認後すぐ
- **影響範囲**: VSCode/Cursor設定のみ
- **リスク**: 低（既存設定のバックアップあり）

### 中期改善（GNU Stow移行）
- **所要時間**: 3-4時間
- **実施タイミング**: 短期改善完了後、時間のある週末
- **影響範囲**: dotfiles全体
- **リスク**: 中（段階的移行でリスク低減）

### 推奨スケジュール

```
Week 1: 短期改善
├── Day 1: バックアップ + 修正適用
├── Day 2: 動作確認
└── Day 3: ドキュメント更新

Week 2-3: 準備期間
├── GNU Stow の理解を深める
├── テスト環境での動作確認
└── 移行手順の精緻化

Week 4: GNU Stow 移行
├── Phase 1: 環境準備
├── Phase 2-3: 構造移行 + リンク作成
├── Phase 4: スクリプト更新
└── Phase 5: 動作確認

Week 5: 安定化
├── 日常利用での問題確認
├── ドキュメント充実化
└── 不要ファイルの削除
```

---

## ✅ 完了チェックリスト

### 短期改善
- [ ] 作業ブランチ作成 (`fix/vscode-cursor-links`)
- [ ] `scripts/setup.zsh` の誤字修正（26-30行目）
- [ ] `scripts/setup.ts` の削除
- [ ] 既存シンボリックリンクの削除
- [ ] セットアップスクリプト再実行 (`/bin/zsh scripts/setup.zsh`)
- [ ] VSCode で設定反映確認
- [ ] Cursor で設定反映確認
- [ ] Git コミット & プッシュ
- [ ] CLAUDE.md 更新（セットアップ手順からsetup.ts削除）

### 中期改善
- [ ] GNU Stow インストール
- [ ] 作業ブランチ作成
- [ ] 既存リンクのバックアップ
- [ ] 新ディレクトリ構造の作成
- [ ] パッケージごとの移行（nvim, vscode, zsh, git, ...）
- [ ] Stow dry-run テスト
- [ ] Stow 本番リンク作成
- [ ] `scripts/setup-stow.sh` 作成
- [ ] 各ツールの動作確認
- [ ] ドキュメント更新（README.md, CLAUDE.md）
- [ ] 旧スクリプトのアーカイブ
- [ ] Git コミット & プッシュ
- [ ] 1週間の日常利用テスト
- [ ] 問題なければブランチマージ

---

## 📚 参考資料

- [GNU Stow 公式ドキュメント](https://www.gnu.org/software/stow/)
- [Dotfiles を GNU Stow で管理する](https://corti.com/effortlessly-manage-dotfiles-on-unix-with-gnu-stow-and-github/)
- [dotfiles.github.io - Utilities](https://dotfiles.github.io/utilities/)
- [ArchWiki - Dotfiles](https://wiki.archlinux.org/title/Dotfiles)
- [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles)

---

## 🤝 貢献者

- **計画作成**: Claude Code
- **実装**: hir0o
- **レビュー**: （必要に応じて）

---

**次のアクション**: 短期改善の実施 → 動作確認 → 中期改善の準備
