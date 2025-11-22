#!/bin/bash
INSTALL_DIR="${INSTALL_DIR:-$HOME/ghq/github.com/hir0o/dotfiles}"

# if [ -d "$INSTALL_DIR" ]; then
#     echo "Updating dotfiles..."
#     git -C "$INSTALL_DIR" pull
# else
#     echo "Installing dotfiles..."
#     git clone https://github.com/hir0o/dotfiles "$INSTALL_DIR"
# fi

export REPO_DIR="$INSTALL_DIR"
/bin/zsh "$INSTALL_DIR/scripts/setup.zsh"
