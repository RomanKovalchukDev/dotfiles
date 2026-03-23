# AI Tools Configuration

This directory contains all AI-related configurations, with primary focus on Claude Code setup inspired by everything-claude-code.

## Structure

```
ai/
├── CLAUDE.md              # Claude Code project-level config
├── AGENTS.md              # Cross-tool agent definitions
│
├── .claude/               # Project-level Claude Code config
│   ├── hooks/             # Project-specific hooks
│   ├── rules/             # Project-level rules
│   └── contexts/          # Dynamic contexts
│
├── claude/                # User-level Claude Code config
│   ├── settings.json      # → ~/.claude/settings.json
│   ├── install.sh         # Skills & agents installer
│   ├── statusline.sh      # Custom status line
│   ├── agents/            # AI personas (2 agents)
│   └── skills/            # Capabilities (49 skills)
│
├── commands/              # Slash commands
├── rules/                 # User-level rules (organized by language)
├── mcp-configs/           # MCP server configurations
├── examples/              # Example configurations
└── cross-platform/        # Support for other AI tools
    ├── .cursor/           # Cursor IDE
    ├── .codex/            # Codex CLI
    └── .opencode/         # OpenCode
```

## Quick Start

### Installation

```bash
# Install all Claude Code skills and agents
./ai/claude/install.sh

# Verify installation
ls -la ~/.claude/skills/ | wc -l    # Should show 49+ skills
ls -la ~/.claude/agents/            # Should show 2 agents
```

### What Gets Installed

- **49 Skills** - Auto-invoked capabilities (marketing, development, content)
- **2 Agents** - Task delegation personas (task-planner, laravel-debugger)
- **Settings** - Global Claude Code settings symlinked to ~/.claude/settings.json
- **Status Line** - Custom status line script

## Configuration Hierarchy

Claude Code reads configuration in this order (later overrides earlier):

1. **`~/.claude/settings.json`** - User-level, global defaults
2. **`CLAUDE.md`** (project root) - Project-specific guidance
3. **`.claude.json`** - Project-level settings (if exists)
4. **`.claude.local.json`** - Local overrides (gitignored)

### When to Use Each

| Config File | Use Case | Example |
|-------------|----------|---------|
| `~/.claude/settings.json` | Personal preferences, global tools | Editor, plugins, permissions |
| `CLAUDE.md` | Project guidance, architecture | Code style, patterns, decisions |
| `.claude.json` | Project settings | Effort level, project-specific rules |
| `.claude.local.json` | Machine-specific overrides | Local paths, personal tweaks |

## Skills (49 Total)

Skills are **auto-invoked capabilities** that Claude uses when relevant. They're directories with `SKILL.md` files.

### Categories

**Marketing & Growth (15 skills):**
- ab-test-setup, analytics-tracking, competitor-alternatives
- content-strategy, copywriting, email-sequence
- form-cro, free-tool-strategy, launch-strategy
- page-cro, pricing-strategy, product-hunt-launch
- retention-strategy, social-media-post, viral-mechanics

**Product & Design (11 skills):**
- building-native-ui, frontend-design, ios-simulator-skill
- laravel-inertia-react-structure, marketing-ideas
- mockup-to-app, native-ux-patterns, onboarding-ux
- react-components, swiftui-components

**Content & Writing (4 skills):**
- copy-editing, twitter-insights, video-hooks, x-thread

**Development Tools (10 skills):**
- agent-browser, context7-auto-research
- convert-github-issue-to-discussion, fix-github-issue
- flare, phpunit-integration-test-writing, ray-skill
- readability, screenshot-to-api-requests

**Business & Strategy (5 skills):**
- ai-wrapper-assessment, market-positioning
- persona-analysis, problem-value-map, value-prop-framework

**Marketing Psychology (1 skill):**
- marketing-psychology

**React Native (1 skill):**
- react-native-best-practices

### Skill Structure

```
skills/ab-test-setup/
├── SKILL.md              # Main definition (YAML + content)
├── references/           # Supporting documentation
│   ├── sample-size-guide.md
│   └── test-templates.md
├── scripts/              # Helper scripts (optional)
└── templates/            # File templates (optional)
```

### Adding New Skills

**Public skill (committed to repo):**
```bash
mkdir -p ai/claude/skills/my-skill
cat > ai/claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
version: 1.0.0
description: Brief description
---

# My Skill

Detailed content...
EOF

./ai/claude/install.sh
```

**Private skill (separate repo):**
```bash
# Set up private repo first
mkdir -p ~/.dotfiles-private/claude/skills/private-skill
echo "Private content" > ~/.dotfiles-private/claude/skills/private-skill/SKILL.md

# Update ai/claude/install.sh with PRIVATE_REPO_URL
# Run installer
./ai/claude/install.sh
```

## Agents (2 Total)

Agents are **AI personas for complex task delegation**. They use the Task tool with limited scope.

### Available Agents

**task-planner** (Opus, Blue):
- Breaks down complex tasks into actionable steps
- Creates structured implementation plans
- Considers dependencies and sequencing
- Model: opus

**laravel-debugger** (Haiku, Red):
- Laravel-specific debugging assistance
- Analyzes errors and suggests fixes
- Model: haiku

### Agent Format

```markdown
---
name: agent-name
description: What this agent does
tools: ["Read", "Grep", "Glob"]
model: opus
---

You are a specialized agent...

## Responsibilities
- Task 1
- Task 2

## How to Work
1. Step 1
2. Step 2
```

## Commands (Slash Commands)

Located in `commands/`, these are user-invoked prompt templates.

**Format:**
```markdown
# Command Name

Command prompt content goes here...
```

**Usage:**
```bash
/command-name
```

**Note:** Currently no commands defined. Add as needed.

## Rules (Coding Guidelines)

Rules are **always-follow guidelines** organized by language, inspired by everything-claude-code.

### Structure

```
rules/
├── common/          # Universal principles (always install)
│   ├── coding-style.md
│   ├── git-workflow.md
│   ├── testing.md
│   └── security.md
├── typescript/      # TS/JS specific
├── python/          # Python specific
├── swift/           # Swift specific
└── php/             # PHP/Laravel specific
```

### Installation

```bash
# User-level (applies to all projects)
mkdir -p ~/.claude/rules
cp -r ai/rules/common/* ~/.claude/rules/
cp -r ai/rules/typescript/* ~/.claude/rules/   # Pick your stack

# Project-level (applies to current project only)
mkdir -p .claude/rules
cp -r ai/rules/common/* .claude/rules/
cp -r ai/rules/php/* .claude/rules/
```

## Hooks

Hooks are **trigger-based automations** that run on specific events.

### Project-Level Hooks (.claude/hooks/)

Located in `ai/.claude/hooks/`, these apply to this dotfiles project:

- **session-start.sh** - Runs when Claude Code session starts
- **pre-tool-use.sh** - Validates operations before execution
- **user-prompt-submit.sh** - Runs when user submits input

### Hook Events

| Event | When | Use Case |
|-------|------|----------|
| SessionStart | Session begins | Load context, show status |
| PreToolUse | Before tool execution | Validate, enforce patterns |
| PostToolUse | After tool execution | Auto-format, verify |
| UserPromptSubmit | User submits input | Sanitize, detect secrets |
| Stop | Session ends | Save state, cleanup |

## MCP Servers

MCP (Model Context Protocol) servers provide external integrations.

### Configuration

Located in `mcp-configs/mcp-servers.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_TOKEN>"
      }
    }
  }
}
```

### Available Servers

Common MCP servers:
- **github** - GitHub API integration
- **supabase** - Supabase database access
- **playwright** - Browser automation
- **filesystem** - File system operations

**Warning:** Too many MCP servers consume context window. Keep under 10 active servers.

## Cross-Platform Support

### Cursor IDE (.cursor/)

Ready for Cursor IDE configurations:
- Hooks (15 event types)
- Rules (YAML frontmatter)
- Agents (via AGENTS.md)

### Codex CLI (.codex/)

Ready for Codex CLI configurations:
- config.toml
- Skills (native format)
- Agent roles

### OpenCode (.opencode/)

Ready for OpenCode configurations:
- Plugin system
- Custom tools
- 11 event types

## Configuration Examples

### settings.json (User-Level)

```json
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(brew:*)"
    ],
    "defaultMode": "ask"
  },
  "effortLevel": "high",
  "statusLine": "~/.dotfiles/ai/claude/statusline.sh"
}
```

### .claude.json (Project-Level)

```json
{
  "permissions": {
    "allow": ["Bash(find:*)"]
  },
  "effortLevel": "high"
}
```

### .claude.local.json (Local Overrides)

```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

## Maintenance

### Update Skills

```bash
# Pull latest
cd ~/.dotfiles
git pull

# Re-run installer (updates symlinks)
./ai/claude/install.sh
```

### Update Private Skills

```bash
# Pull private repo
cd ~/.dotfiles-private
git pull

# Re-activate
cd ~/.dotfiles
./ai/claude/install.sh
```

### Remove Skill

```bash
# Remove from repo
rm -rf ai/claude/skills/unwanted-skill
git commit -am "Remove unwanted skill"

# Remove symlink
rm ~/.claude/skills/unwanted-skill
```

### Verify Active Skills

```bash
# Count skills
ls -la ~/.claude/skills/ | wc -l

# List all skills
ls ~/.claude/skills/

# Check specific skill
ls -la ~/.claude/skills/ab-test-setup
```

## Token Optimization

Claude Code usage can be expensive. These settings reduce costs:

### Recommended Settings

```json
{
  "model": "sonnet",
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  }
}
```

### Daily Workflow

| Command | When to Use |
|---------|-------------|
| `/model sonnet` | Default for most tasks |
| `/model opus` | Complex architecture, debugging |
| `/clear` | Between unrelated tasks (free reset) |
| `/compact` | At logical breakpoints |
| `/cost` | Monitor token spending |

## Troubleshooting

### Skills Not Activating

```bash
# Check installation
ls ~/.claude/skills/

# Re-run installer
./ai/claude/install.sh

# Check symlinks
ls -la ~/.claude/skills/ab-test-setup
```

### Hooks Not Running

```bash
# Check hook files
ls -la ai/.claude/hooks/

# Check executable permissions
chmod +x ai/.claude/hooks/*.sh

# Test manually
./ai/.claude/hooks/session-start.sh
```

### Settings Not Loading

```bash
# Check settings file
cat ~/.claude/settings.json

# Check project config
cat CLAUDE.md

# Check local overrides
cat .claude.local.json
```

## Resources

- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code
- **everything-claude-code**: https://github.com/affaan-m/everything-claude-code
- **Skills Reference**: `ai/claude/README.md`
- **Agent Definitions**: `AGENTS.md`

## Next Steps

1. **Install skills**: `./ai/claude/install.sh`
2. **Configure settings**: Edit `~/.claude/settings.json`
3. **Add rules**: Copy from `ai/rules/` to `~/.claude/rules/`
4. **Test hooks**: Start new Claude Code session
5. **Customize**: Add your own skills, agents, commands
