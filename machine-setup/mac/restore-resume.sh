#!/bin/bash
#
# Restore macOS Resume Feature
# Run this to re-enable app/window restoration after restart

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}🔄 Restoring macOS Resume Feature${NC}"
echo ""
echo "This will re-enable automatic restoration of apps and windows after restart."
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}Step 1: Enabling Resume system-wide${NC}"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true
echo -e "${GREEN}✓${NC} Resume enabled for applications"

echo ""
echo -e "${BLUE}Step 2: Enabling window restoration on login${NC}"
defaults write com.apple.loginwindow TALLogoutSavesState -bool true
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool true
echo -e "${GREEN}✓${NC} Login window restoration enabled"

echo ""
echo -e "${GREEN}✅ Resume feature restored!${NC}"
echo ""
echo "Your apps and windows will now be restored after restart."
echo ""
echo -e "${YELLOW}Note: You may need to log out and back in for changes to take effect.${NC}"
echo ""
