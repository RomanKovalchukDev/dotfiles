#!/bin/bash
#
# AI Configuration Setup
# Layered architecture: ECC Plugin (Layer 2) + Personal Configs (Layer 3)

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 Setting up AI configuration (Claude Code)${NC}"
echo ""

# Detect dotfiles directory
if [ -n "$DOTFILES_DIR" ]; then
  DOTFILES="$DOTFILES_DIR"
elif [ -d "$HOME/.dotfiles" ]; then
  DOTFILES="$HOME/.dotfiles"
elif [ -d "$HOME/Documents/dotfiles" ]; then
  DOTFILES="$HOME/Documents/dotfiles"
else
  echo -e "${YELLOW}⚠️  Could not find dotfiles directory${NC}"
  echo "Please set DOTFILES_DIR environment variable or create ~/.dotfiles symlink"
  exit 1
fi

echo -e "${GREEN}📁 Using dotfiles at: $DOTFILES${NC}"
echo ""

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
  echo -e "${YELLOW}⚠️  Claude Code CLI not found${NC}"
  echo "Install Claude Code first: https://code.claude.com"
  exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Layer 1: Claude Code Core (Already installed ✓)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Layer 2: Everything Claude Code Plugin${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}📦 Installing plugin marketplaces + plugins from manifest...${NC}"
echo ""

# Manifest-driven install: ECC, official swift/clangd LSPs, superpowers,
# wshobson (SQL database-design + deployment), VGV flutter.
# Edit ai/.claude/plugins/plugins.manifest to change what gets installed.
if [ -f "$DOTFILES/ai/.claude/plugins/install-plugins.sh" ]; then
  bash "$DOTFILES/ai/.claude/plugins/install-plugins.sh" || \
    echo -e "${YELLOW}⚠️  Some plugins failed to install (continuing...)${NC}"
  echo -e "${GREEN}✓ Plugins installed from manifest${NC}"
else
  echo -e "${YELLOW}⚠️  plugins/install-plugins.sh not found, skipping${NC}"
fi
echo ""

# Install ECC rules manually (plugin limitation - rules can't be distributed via plugins)
echo -e "${GREEN}📝 Installing ECC rules...${NC}"
ECC_REPO="$HOME/Documents/PersonalProjects/setup/everything-claude-code"

if [ -d "$ECC_REPO" ]; then
  mkdir -p ~/.claude/rules

  # Install common rules (always needed)
  cp -r "$ECC_REPO/rules/common/"* ~/.claude/rules/ 2>/dev/null || true
  echo "  ✓ Common rules"

  # Install language-specific rules
  cp -r "$ECC_REPO/rules/typescript/"* ~/.claude/rules/ 2>/dev/null || true
  echo "  ✓ TypeScript/JavaScript rules"

  cp -r "$ECC_REPO/rules/python/"* ~/.claude/rules/ 2>/dev/null || true
  echo "  ✓ Python rules"

  cp -r "$ECC_REPO/rules/golang/"* ~/.claude/rules/ 2>/dev/null || true
  echo "  ✓ Go rules"

  cp -r "$ECC_REPO/rules/swift/"* ~/.claude/rules/ 2>/dev/null || true
  echo "  ✓ Swift rules"

  cp -r "$ECC_REPO/rules/csharp/"* ~/.claude/rules/ 2>/dev/null || true
  echo "  ✓ C# rules"

  cp -r "$ECC_REPO/rules/kotlin/"* ~/.claude/rules/ 2>/dev/null || true
  echo "  ✓ Kotlin rules"

  cp -r "$ECC_REPO/rules/rust/"* ~/.claude/rules/ 2>/dev/null || true
  echo "  ✓ Rust/C++ rules"

  echo -e "${GREEN}✓ ECC rules installed${NC}"
else
  echo -e "${YELLOW}⚠️  ECC repo not found at $ECC_REPO${NC}"
  echo "Skipping ECC rules installation. Clone the repo manually if needed."
fi

echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}MCP Servers${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}🔌 Registering MCP servers from manifest...${NC}"
# stdio servers (context7, firebase, xcode, plantuml, frame0, roadmapsh,
# office-word) register immediately. HTTP servers (notion, nerdz) still need a
# one-time interactive login afterwards. See ai/.claude/mcp-configs/.
if [ -f "$DOTFILES/ai/.claude/mcp-configs/install-mcp.sh" ]; then
  bash "$DOTFILES/ai/.claude/mcp-configs/install-mcp.sh" || \
    echo -e "${YELLOW}⚠️  Some MCP servers failed to register (continuing...)${NC}"
  echo -e "${GREEN}✓ MCP servers registered${NC}"
  echo "  HTTP servers need a one-time login: claude mcp login notion && claude mcp login nerdz"
else
  echo -e "${YELLOW}⚠️  mcp-configs/install-mcp.sh not found, skipping${NC}"
fi
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Layer 3: Personal Configurations${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}🔧 Symlinking personal configs...${NC}"

# Create .claude directory if it doesn't exist
mkdir -p ~/.claude/agents ~/.claude/skills ~/.claude/rules ~/.claude/scripts

# Symlink personal preferences
ln -sf "$DOTFILES/ai/.claude/CLAUDE.md" ~/.claude/CLAUDE.md
echo "  ✓ CLAUDE.md (personal preferences)"

# Symlink settings (security, statusline, permissions)
ln -sf "$DOTFILES/ai/.claude/settings.json" ~/.claude/settings.json
echo "  ✓ settings.json (security, statusline)"

# Symlink personal agents
for agent in "$DOTFILES/ai/.claude/agents"/*.md; do
  if [ -f "$agent" ]; then
    ln -sf "$agent" ~/.claude/agents/
    echo "  ✓ $(basename "$agent")"
  fi
done

# Symlink personal skills
for skill_dir in "$DOTFILES/ai/.claude/skills"/*; do
  if [ -d "$skill_dir" ]; then
    skill_name=$(basename "$skill_dir")
    ln -sf "$skill_dir" ~/.claude/skills/
    echo "  ✓ $skill_name/"
  fi
done

# Symlink personal rules
for rule in "$DOTFILES/ai/.claude/rules"/*.md; do
  if [ -f "$rule" ]; then
    ln -sf "$rule" ~/.claude/rules/
    echo "  ✓ $(basename "$rule")"
  fi
done

# Symlink statusline script
ln -sf "$DOTFILES/ai/scripts/statusline.sh" ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
echo "  ✓ statusline.sh"

echo ""
echo -e "${GREEN}✓ Personal configs symlinked${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ AI Configuration Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Setup summary:"
echo "  Layer 1: Claude Code Core ✓"
echo "  Layer 2: Plugins from manifest (ECC, LSPs, superpowers, wshobson, VGV) ✓"
echo "  MCP:     Global servers registered from manifest ✓"
echo "  Layer 3: Personal configs (CLAUDE.md, agents, skills, statusline) ✓"
echo ""
echo "Next: restart Claude Code to load plugins/skills, then for HTTP MCPs run:"
echo "     claude mcp login notion && claude mcp login nerdz"
echo ""
echo "Try: claude"
echo "     /everything-claude-code:plan \"Add user authentication\""
echo ""
