# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## 重要

ユーザーには日本語で対応すること

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
# Set up everything (dotfiles, tools, Homebrew packages) in one command
mise bootstrap

# Apply only the dotfiles
mise dotfiles apply

# Check what is out of sync without changing anything
mise dotfiles status
mise dotfiles apply --dry-run
```

## Architecture & Key Components

### Directory Structure
- `mise.toml` - Single source of truth. `[dotfiles]` declares where each package is
  linked, `[tasks.bootstrap]` handles Homebrew and APM installation
- `packages/` - Configuration sources, one directory per tool. The contents are
  linked to the target declared in `mise.toml`, so the directory layout itself
  carries no meaning
- `scripts/` - Auxiliary scripts not covered by mise

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

**Yazi (`packages/yazi/`)**
- Modern terminal file manager
- Configuration in `yazi.toml` with XDG-compliant paths
- `show_hidden = true` enabled for displaying hidden files by default

### Key Environment Variables
The setup relies on XDG Base Directory specification:
- `XDG_CONFIG_HOME` - Configuration files (default: `~/.config`)
- `XDG_DATA_HOME` - Data files (default: `~/.local/share`)
- `XDG_STATE_HOME` - State files (default: `~/.local/state`)
- `XDG_CACHE_HOME` - Cache files (default: `~/.cache`)

### Development Tools Managed
- Package managers: Homebrew, pnpm, cargo, bun, deno
- Version managers: mise - versions are declared in `packages/mise/config.toml`
  (Java, Kotlin, Node.js, pnpm). proto was replaced by mise and is no longer used
- Terminal emulators: iTerm2, Alacritty
- Shell utilities: fzf, ripgrep, gh, ghq, delta, yazi
- Development: Node.js ecosystem, Rust, Go, Android SDK

## Important Notes

1. This repository uses **mise** (`[dotfiles]` in `mise.toml`) for symlink management.
   It was migrated from GNU Stow; see the `feat/migrate-to-mise-dotfiles` history for details
2. Link targets live in `mise.toml`, **not** in the directory structure. Unlike Stow,
   `packages/nvim/` needs no `.config/nvim/` intermediate layer
3. Dotfiles are only applied when explicitly requested (`mise dotfiles apply` or
   `mise bootstrap`). They are never applied implicitly
4. Avoid editing files directly in system locations (e.g., `~/.config/nvim`) - edit files in this repository instead
5. VSCode settings are linked to `~/Library/Application Support/Code/User/`, and Cursor
   shares them by linking `settings.json` / `keybindings.json` / `snippets` individually
   (Cursor's own `globalStorage` and `History` must stay intact)
6. `herdr` and `cmux` use `symlink-each` because runtime artifacts (logs, sockets) live
   alongside the config in the target directory. Linking the whole directory would put
   those artifacts inside this repository
7. To add a package: create `packages/<name>/` and add a `[dotfiles]` entry, then run
   `mise dotfiles apply`. `mise dotfiles add <target>` can generate the entry from a live file
8. Git configuration includes many fzf-based interactive commands that require fzf to be installed
9. Many shell aliases depend on tools installed via Homebrew - ensure Brewfile is installed first
10. `packages/zsh/zshenv.local` is encrypted with git-crypt. If it is ever moved, update
    `.gitattributes` in the same commit and verify with `git-crypt status`
