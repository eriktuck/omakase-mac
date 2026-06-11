# Project: macOS-Omarchy (Apple Silicon Developer Environment)

## 1. Project Philosophy
This project ports the "Omarchy" Linsux philosophy to macOS. The goal is to create an "omakase" (curated, high-quality, pre-configured) developer environment that relies strictly on fast, cross-platform CLI tools. 

Instead of fighting the macOS kernel, this setup leverages native Apple Silicon optimizations (like Ghostty's Metal rendering) while maintaining a strict, keyboard-centric, tiling-window workflow via AeroSpace and Tmux.

## 2. Core Architecture
The repository is designed to be completely scriptable and highly upgradable without relying on fragile bash translations of Linux system packages. It is built on three distinct configuration layers:

1. **The Package Layer (`Brewfile`):** A declarative list of all CLI tools, fonts, and GUI applications managed entirely by Homebrew.
2. **The Config Layer (`GNU Stow`):** A symlink farm manager that maps dotfiles from the repository directory directly to `~/.config/` or `~/`, allowing version control without manual copying.
3. **The OS Layer (`defaults`):** A bash script executing macOS `defaults write` commands to automatically strip away Apple's default GUI animations, reveal hidden files, and optimize mission control for a tiling workflow.

## 3. The Developer Toolchain
The core stack replaces bloated legacy utilities with modern, Rust-based alternatives, mirroring the Omarchy Linux experience.

| Category           | Tool        | Purpose / Configuration Notes                                |
| :----------------- | :---------- | :----------------------------------------------------------- |
| **Terminal**       | `ghostty`   | GPU-accelerated (Metal) terminal. Configured with macOS-native global toggle (`Ctrl+Esc`) and Option-as-Meta mapped for Tmux compatibility. |
| **Multiplexer**    | `tmux`      | Handles all window panes, sessions, and background persistence. |
| **Window Manager** | `AeroSpace` | i3-like tiling window manager for macOS. Bypasses native Mission Control sliding animations for instant workspace switching. |
| **Editor**         | `neovim`    | The core IDE. Built on the `LazyVim` starter framework for out-of-the-box LSP integration, synced to the macOS system clipboard. |
| **Shell Prompt**   | `starship`  | Fast, customizable, cross-shell prompt written in Rust.      |
| **Modern `ls`**    | `eza`       | Icon-aware, colorized directory listings (`alias ls="eza --icons"`). |
| **Modern `cat`**   | `bat`       | Syntax highlighting and Git integration for reading files in stdout. |
| **Fuzzy Finder**   | `fzf`       | Universal command-line fuzzy finder for files, history, and processes. |
| **Search**         | `ripgrep`   | Blistering fast text search (`rg`); powers LazyVim telescope and CLI grepping. |
| **Source Control** | `lazygit`   | Terminal UI for Git operations, eliminating the need for a GUI client. |

## 4. Repository Structure
The project must adhere to this XDG-compliant structure to allow GNU Stow to map files cleanly:

```text
~/.omakase-mac/
├── install.sh             # Master bootstrap script (Brew + Stow + OS Defaults)
├── Brewfile               # Declarative package list
├── macos/
│   └── defaults.sh        # macOS system preferences script
├── ghostty/
│   └── .config/ghostty/   # Ghostty configuration files
├── nvim/
│   └── .config/nvim/      # LazyVim template and custom lua configs
├── tmux/
│   └── .config/tmux/      # Tmux configuration and plugin definitions
├── zsh/
│   └── .zshrc             # Shell aliases (c, cx, eza, bat) and history limits
```

## 5. Implementation Phases

- **Phase 1: Bootstrapping.** Establish the `install.sh` script to verify Homebrew installation, execute the `Brewfile`, and install GNU Stow.
- **Phase 2: Configuration Linking.** Populate the respective directories (`ghostty`, `nvim`, `tmux`, `zsh`) with their baseline Omarchy-equivalent configurations and execute `stow`.
- **Phase 3: OS Hardening.** Run `macos/defaults.sh` to configure key repeat rates, disable Mission Control auto-arranging, show hidden files, and map specific keyboard modifier behaviors.