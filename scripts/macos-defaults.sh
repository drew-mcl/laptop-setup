#!/usr/bin/env bash
set -euo pipefail

if [[ "$OSTYPE" != darwin* ]]; then
  echo "[macos] Non-macOS detected; skipping."
  exit 0
fi

echo "[macos] Applying safe macOS defaults..."

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar and path bar
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Finder: search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Always open folders in list view
defaults write com.apple.Finder FXPreferredViewStyle -string "Nlsv"

# Dock: auto-hide and speed up animation
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.2
defaults write com.apple.dock autohide-delay -float 0.0

# Keyboard: enable key repeat, disable press-and-hold
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Save to disk (not iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Show Library folder
chflags nohidden ~/Library

# Apply
killall Finder >/dev/null 2>&1 || true
killall Dock >/dev/null 2>&1 || true

echo "[macos] Done. Some changes may require logout/restart."

