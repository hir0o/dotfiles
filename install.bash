#!/bin/bash
set -euo pipefail

INSTALL_DIR="$(pwd)"

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

# mise.toml を信頼した上で、dotfiles の配置・ツール導入・
# Homebrew パッケージのインストールまでを一括で実行する
mise trust
mise bootstrap --yes
