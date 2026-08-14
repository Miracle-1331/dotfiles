#!/usr/bin/env bash
# Sensible macOS defaults. Idempotent — safe to re-run.
# Comment out any block you don't want.
set -euo pipefail

echo "Applying macOS defaults (some changes require logout/restart)..."

# --- Keyboard --------------------------------------------------------------
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# --- Finder ----------------------------------------------------------------
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"      # search current folder
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# --- Screenshots -----------------------------------------------------------
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# --- Dock ------------------------------------------------------------------
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false        # don't rearrange Spaces

# --- Trackpad --------------------------------------------------------------
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# --- Restart affected apps -------------------------------------------------
for app in Finder Dock SystemUIServer; do
  killall "$app" 2>/dev/null || true
done

echo "macOS defaults applied."
