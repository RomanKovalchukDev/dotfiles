#!/bin/bash
#
# Fix Spotlight Search
# Run this if Cmd+Space shows the icon but doesn't open the search window

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}🔍 Fixing Spotlight Search${NC}"
echo ""

# Ask for administrator password upfront
sudo -v

echo -e "${YELLOW}This will restart Spotlight and rebuild its index.${NC}"
echo -e "${YELLOW}The rebuild may take several minutes to complete.${NC}"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}Step 1: Killing Spotlight processes${NC}"
sudo killall mds > /dev/null 2>&1 || true
killall Spotlight > /dev/null 2>&1 || true
echo -e "${GREEN}✓${NC} Processes terminated"

echo ""
echo -e "${BLUE}Step 2: Unloading Spotlight${NC}"
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist > /dev/null 2>&1 || true
echo -e "${GREEN}✓${NC} Spotlight unloaded"

echo ""
echo -e "${BLUE}Step 3: Reloading Spotlight${NC}"
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist
echo -e "${GREEN}✓${NC} Spotlight reloaded"

echo ""
echo -e "${BLUE}Step 4: Rebuilding Spotlight index${NC}"
echo -e "${YELLOW}Note: This will take several minutes depending on your disk size${NC}"
sudo mdutil -E /
echo -e "${GREEN}✓${NC} Index rebuild started"

echo ""
echo -e "${BLUE}Step 5: Restarting Spotlight${NC}"
killall Spotlight > /dev/null 2>&1 || true
echo -e "${GREEN}✓${NC} Spotlight restarted"

echo ""
echo -e "${GREEN}✅ Spotlight fix complete!${NC}"
echo ""
echo "Try Cmd+Space now. If it still doesn't work:"
echo "1. Wait a few minutes for indexing to complete"
echo "2. Check System Settings → Siri & Spotlight → Keyboard Shortcuts"
echo "3. Restart your Mac"
echo ""
