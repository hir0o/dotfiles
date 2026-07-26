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

mise trust
mise bootstrap --yes
