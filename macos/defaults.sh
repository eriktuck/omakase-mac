#!/usr/bin/env bash
# omakase-mac — macOS system preferences (OS layer)
# Idempotent: safe to run repeatedly. Re-run after macOS upgrades.
set -euo pipefail

echo "==> Applying macOS defaults..."

# Close System Settings to avoid clobbering our writes.
osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true

# --- Keyboard: fast key repeat, no press-and-hold accent menu ---
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# --- Finder: show hidden files & all extensions, POSIX path in title ---
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# --- Spotlight: free up cmd+space for Raycast ---
# Symbolic hotkey ID 64 = "Show Spotlight search". Disable it so Raycast can
# claim cmd+space. (Set Raycast's hotkey in Raycast's onboarding / settings.)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 \
  '{ enabled = 0; value = { parameters = (32, 49, 1048576); type = standard; }; }'
# Reload the symbolic-hotkeys settings so the change takes effect without logout.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u >/dev/null 2>&1 || true

# --- Mission Control: tiling-friendly (no auto-rearrange, no animations) ---
defaults write com.apple.dock mru-spaces -bool false                 # don't reorder spaces
defaults write com.apple.dock expose-animation-duration -float 0     # instant Mission Control
defaults write com.apple.dock workspaces-auto-swoosh -bool false     # no space-switch swoosh
defaults write com.apple.dock autohide-time-modifier -float 0        # instant Dock hide
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide -bool true

# --- UI animations: reduce for a snappier, tiling-style feel ---
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# --- Save / print panels: always expanded ---
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# --- Misc quality-of-life ---
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false   # default save to disk
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"

# --- Apply: restart affected apps ---
for app in Finder Dock SystemUIServer; do
  killall "$app" >/dev/null 2>&1 || true
done

echo "==> macOS defaults applied. Some changes may require logout/restart to fully take effect."
