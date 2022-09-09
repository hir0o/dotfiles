#!bin/bash
set -eu

REPO_DIR="${REPO_DIR:-$HOME/ghq/github.com/hir0o/dotfiles}"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"


# Install Homebrew
if type brew >/dev/null; then
    echo "Homebrew is already installed."
else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

brew update
brew bundle install --file "$REPO_DIR/config/homebrew/Brewfile"

# setup link
echo "Setting up links..."
ln -sfv "$REPO_DIR/config/"* "$XDG_CONFIG_HOME"
ln -sfv "$XDG_CONFIG_HOME/zsh/.zshenv" "$HOME/.zshenv"

VSCODE_PATH="$HOME/Library/Application\ Support/Code/User"
mkdir -p "$VSCODE_PATH"
ls $VSCODE_PATH
ln -sfv  "$XDG_CONFIG_HOME/vscode/"* VSCODE_PATH
