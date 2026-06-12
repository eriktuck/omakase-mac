#!/usr/bin/env bash
# omakase-mac — master bootstrap. Idempotent: safe to re-run.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.omakase-backup/$(date +%Y%m%d-%H%M%S)"
STOW_PACKAGES=(zsh ghostty tmux aerospace starship nvim sketchybar)

info()  { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
warn()  { printf "\033[1;33m!!\033[0m %s\n" "$1"; }

# 1. Xcode Command Line Tools -------------------------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing Xcode Command Line Tools (follow the GUI prompt, then re-run)..."
  xcode-select --install
  exit 1
fi

# 2. Homebrew -----------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Packages -----------------------------------------------------------------
# Newer Homebrew refuses to build formulae from third-party taps until trusted.
info "Trusting third-party taps..."
brew trust felixkratz/formulae || warn "Could not trust felixkratz/formulae; SketchyBar may fail to install."
info "Installing packages from Brewfile..."
brew bundle --file="$REPO/Brewfile"

# 4. Back up conflicting dotfiles --------------------------------------------
# Stow refuses to overwrite real files. Move any that exist (and aren't already
# our symlinks) into a timestamped backup so stow can take over cleanly.
backup_if_real() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    info "Backing up $target -> $BACKUP_DIR/"
    mv "$target" "$BACKUP_DIR/"
  fi
}
backup_if_real "$HOME/.zshrc"
backup_if_real "$HOME/.zprofile"
backup_if_real "$HOME/.config/ghostty/config"
backup_if_real "$HOME/.config/tmux/tmux.conf"
backup_if_real "$HOME/.config/aerospace/aerospace.toml"
backup_if_real "$HOME/.config/starship.toml"

# 5. Stow symlinks ------------------------------------------------------------
# Repo lives in $HOME, so stow's default target is $HOME (no --target needed).
info "Linking configs with GNU Stow..."
cd "$REPO"
stow --restow "${STOW_PACKAGES[@]}"

# 6. Tmux plugin manager (TPM) + plugins -------------------------------------
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  info "Cloning TPM (tmux plugin manager)..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
info "Installing tmux plugins..."
"$TPM_DIR/bin/install_plugins" || warn "TPM install reported issues; run 'prefix + I' inside tmux."

# 7. Neovim: sync pinned plugins headlessly ----------------------------------
info "Syncing Neovim (LazyVim) plugins..."
nvim --headless "+Lazy! restore" +qa 2>/dev/null || \
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || \
  warn "Neovim plugin sync had issues; open nvim and run :Lazy."

# 8. macOS system defaults ----------------------------------------------------
info "Applying macOS system defaults..."
bash "$REPO/macos/defaults.sh"

# 8b. SketchyBar service ------------------------------------------------------
# `restart` is idempotent: starts it if stopped, reloads config if running.
info "Starting SketchyBar..."
brew services restart sketchybar || warn "Could not start SketchyBar; run 'brew services start sketchybar'."

# 9. Manual follow-ups --------------------------------------------------------
cat <<'EOF'

============================================================
  omakase-mac bootstrap complete. Manual steps remaining:
============================================================
  1. git identity:
       git config --global user.name  "Your Name"
       git config --global user.email "you@example.com"
  2. Grant AeroSpace Accessibility permission, then launch it:
       System Settings > Privacy & Security > Accessibility
  3. Grant Ghostty Accessibility permission (for the global
       Ctrl+Esc quick-terminal hotkey).
  4. Restart your shell (or open a new Ghostty window).
============================================================
EOF
