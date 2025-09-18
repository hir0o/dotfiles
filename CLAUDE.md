# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a dotfiles repository for macOS development environment setup. It manages configurations for various development tools including Neovim, VSCode, Zsh, Git, and more.

## Setup Commands

### Initial Setup
```bash
# Clone and run the installation script
sh -c "`curl -fsSL https://raw.githubusercontent.com/hir0o/dotfiles/master/install.bash`"

# Or use the interactive Deno TypeScript setup (requires root)
sudo deno run -A scripts/setup.ts
```

### Manual Setup Steps
```bash
# Install Homebrew packages
brew bundle install --file config/homebrew/Brewfile

# Create symbolic links
ln -sfv $HOME/ghq/github.com/hir0o/dotfiles/config/* $HOME/.config
ln -sfv $HOME/.config/zsh/.zshenv $HOME/.zshenv
```

## Architecture & Key Components

### Directory Structure
- `config/` - All tool configurations following XDG Base Directory specification
- `scripts/` - Setup scripts (both Zsh and Deno TypeScript versions)
- Configurations are organized by tool name under `config/`

### Critical Configurations

**Git (`config/git/`)**
- Extensive custom aliases using fzf for interactive operations
- Delta diff viewer integration
- GPG commit signing enabled
- Custom functions for branch management, commit selection, and GitHub integration

**Neovim (`config/nvim/`)**
- Modern Lua-based configuration
- Lazy.nvim for plugin management
- LSP setup for multiple languages
- Custom keymaps and colorscheme configurations

**Zsh (`config/zsh/`)**
- Powerlevel10k prompt theme
- Sheldon plugin manager
- Custom aliases organized in `aliases/` directory
- Environment variables follow XDG spec

**VSCode (`config/vscode/`)**
- Settings, keybindings, and snippets for JavaScript/TypeScript development
- Vim mode enabled with custom bindings
- Integration with various extensions

### Key Environment Variables
The setup relies on XDG Base Directory specification:
- `XDG_CONFIG_HOME` - Configuration files (default: `~/.config`)
- `XDG_DATA_HOME` - Data files (default: `~/.local/share`)
- `XDG_STATE_HOME` - State files (default: `~/.local/state`)
- `XDG_CACHE_HOME` - Cache files (default: `~/.cache`)

### Development Tools Managed
- Package managers: Homebrew, pnpm, cargo, proto, bun, deno
- Version managers: proto (for Node.js, pnpm, bun)
- Terminal emulators: iTerm2, Alacritty
- Shell utilities: fzf, ripgrep, gh, ghq, delta
- Development: Node.js ecosystem, Rust, Go, Android SDK

## Important Notes

1. The setup scripts create symbolic links from this repository to system locations - avoid editing files directly in system locations
2. VSCode settings are linked to `~/Library/Application Support/Code/User/`
3. The Deno setup script (`scripts/setup.ts`) requires root access and is interactive
4. Git configuration includes many fzf-based interactive commands that require fzf to be installed
5. Many shell aliases depend on tools installed via Homebrew - ensure Brewfile is installed first