# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a dotfiles repository for macOS development environment setup. It manages configurations for various development tools including Neovim, VSCode, Zsh, Git, and more.

## Setup Commands

### Initial Setup
```bash
# Clone and run the installation script
sh -c "`curl -fsSL https://raw.githubusercontent.com/hir0o/dotfiles/master/install.bash`"
```

### Manual Setup Steps
```bash
# Install Homebrew packages (includes GNU Stow)
brew bundle install --file ~/.config/homebrew/Brewfile

# Create symbolic links using GNU Stow
bash scripts/setup-stow.sh
```

## Architecture & Key Components

### Directory Structure
- `packages/` - GNU Stow packages, each containing configurations in their target directory structure
- `scripts/` - Setup scripts for initial environment setup
  - `setup-stow.sh` - Main setup script using GNU Stow
  - `archive/` - Archived legacy setup scripts
- Configurations are organized by tool name under `packages/`

### Critical Configurations

**Git (`packages/git/`)**
- Extensive custom aliases using fzf for interactive operations
- Delta diff viewer integration
- GPG commit signing enabled
- Custom functions for branch management, commit selection, and GitHub integration

**Neovim (`packages/nvim/`)**
- Modern Lua-based configuration
- Lazy.nvim for plugin management
- LSP setup for multiple languages
- Custom keymaps and colorscheme configurations

**Zsh (`packages/zsh/`)**
- Powerlevel10k prompt theme
- Sheldon plugin manager
- Custom aliases organized in `aliases/` directory
- Environment variables follow XDG spec

**VSCode (`packages/vscode/`)**
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

1. This repository uses **GNU Stow** for symlink management - a standard tool for managing dotfiles
2. The setup script (`scripts/setup-stow.sh`) creates symbolic links from `packages/` to their target locations
3. Avoid editing files directly in system locations (e.g., `~/.config/nvim`) - edit files in this repository instead
4. VSCode settings are managed by Stow and linked to `~/Library/Application Support/Code/User/`
5. Cursor settings are linked to VSCode settings for consistency
6. Git configuration includes many fzf-based interactive commands that require fzf to be installed
7. Many shell aliases depend on tools installed via Homebrew - ensure Brewfile is installed first
8. To add/remove packages: use `stow` command directly (e.g., `stow -d packages -t ~ <package>`)
9. Legacy setup scripts are archived in `scripts/archive/` for reference