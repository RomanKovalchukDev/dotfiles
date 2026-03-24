#!/usr/bin/env bash
#
# Fix sharing extensions by restoring LSQuarantine
#

echo "Restoring LSQuarantine to fix sharing extensions..."

# Re-enable Gatekeeper quarantine system
defaults write com.apple.LaunchServices LSQuarantine -bool true

echo "✓ LSQuarantine restored"
echo ""
echo "You may need to log out and back in for changes to take effect."
echo "Or run: killall Finder cfprefsd SystemUIServer"
