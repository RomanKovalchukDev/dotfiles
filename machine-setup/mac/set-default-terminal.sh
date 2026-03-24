#!/usr/bin/env bash
#
# Set Ghostty as the default terminal application on macOS

# Check if Ghostty is installed
if [ ! -d "/Applications/Ghostty.app" ]; then
  echo "Ghostty is not installed. Skipping default terminal setup."
  exit 0
fi

echo "Setting Ghostty as default terminal..."

# Get Ghostty bundle identifier
GHOSTTY_BUNDLE_ID=$(osascript -e 'id of app "Ghostty"')

if [ -z "$GHOSTTY_BUNDLE_ID" ]; then
  echo "Could not determine Ghostty bundle identifier"
  exit 1
fi

echo "Ghostty bundle ID: $GHOSTTY_BUNDLE_ID"

# Set Ghostty as default terminal in Desktop & Dock preferences
# This sets the default terminal for "Open in Terminal" commands
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
  "{LSHandlerContentType=public.unix-executable;LSHandlerRoleAll=$GHOSTTY_BUNDLE_ID;}"

# Set Ghostty as handler for terminal:// URLs
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
  "{LSHandlerURLScheme=terminal;LSHandlerRoleAll=$GHOSTTY_BUNDLE_ID;}"

# Rebuild Launch Services database
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo "Ghostty is now set as the default terminal"
echo "You may need to log out and log back in for changes to take full effect"

exit 0
