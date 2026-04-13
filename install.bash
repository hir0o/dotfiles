#!/bin/bash
INSTALL_DIR="$(pwd)"

# if [ -d "$INSTALL_DIR" ]; then
#     echo "Updating dotfiles..."
#     git -C "$INSTALL_DIR" pull
# else
#     echo "Installing dotfiles..."
#     git clone https://github.com/hir0o/dotfiles "$INSTALL_DIR"
# fi

# bunがインストールされていなければインストール
if ! command -v bun &> /dev/null; then
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
fi

export REPO_DIR="$INSTALL_DIR"
/bin/bash "$INSTALL_DIR/scripts/setup.sh"
