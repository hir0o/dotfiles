#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/hir0o/dotfiles.git"

# リポジトリの中で実行された場合はそのまま使い、それ以外は clone する
if [ -f "mise.toml" ] && [ -d "packages" ]; then
    INSTALL_DIR="$(pwd)"
else
    INSTALL_DIR="${DOTFILES_DIR:-$HOME/ghq/github.com/hir0o/dotfiles}"
    if [ ! -d "$INSTALL_DIR/.git" ]; then
        echo "Cloning dotfiles into $INSTALL_DIR..."
        git clone "$REPO_URL" "$INSTALL_DIR"
    fi
fi

# bunがインストールされていなければインストール
if ! command -v bun &> /dev/null; then
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
fi

# miseがインストールされていなければインストール
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

cd "$INSTALL_DIR"

mise trust
mise bootstrap --yes
