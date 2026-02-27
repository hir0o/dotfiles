#!/bin/bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/ghq/github.com/hir0o/dotfiles}"
STOW_DIR="$REPO_DIR/packages"

echo "Setting up dotfiles with GNU Stow..."
echo "Repository: $REPO_DIR"
echo ""

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
    "zsh"
    "zellij"
    "git"
    "tmux"
    "homebrew"
    "karabiner"
    "p10k"
    "sheldon"
    "wezterm"
    "yazi"
    "ghostty"
    "octorus"
)

echo "Stowing packages..."
for package in "${PACKAGES[@]}"; do
    if [ -d "$STOW_DIR/$package" ]; then
        echo "  Stowing $package..."
        stow -v -d "$STOW_DIR" -t "$HOME" "$package"
    else
        echo "  Warning: Package $package not found, skipping..."
    fi
done

echo ""
echo "Setting up Cursor settings (linked to VSCode)..."
mkdir -p "$HOME/Library/Application Support/Cursor/User"
cd "$HOME/Library/Application Support/Cursor/User"

# 既存のシンボリックリンクを削除
rm -f settings.json keybindings.json
rm -rf snippets

# VSCodeの設定にリンク
ln -s ../../Code/User/settings.json settings.json
ln -s ../../Code/User/keybindings.json keybindings.json
ln -s ../../Code/User/snippets snippets

cd "$REPO_DIR"

echo ""
echo "Done! All packages have been stowed."
echo ""
echo "Stowed packages:"
for package in "${PACKAGES[@]}"; do
    if [ -d "$STOW_DIR/$package" ]; then
        echo "  ✓ $package"
    fi
done
echo ""
echo "Cursor settings are now linked to VSCode settings."
