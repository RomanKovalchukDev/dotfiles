# Claude Code Configuration

Comprehensive Claude Code setup for this dotfiles repository, including 49 skills, agents, hooks, and configuration hierarchy.

## Quick Start

```bash
# Activate all 49 skills
./claude/install.sh

# Verify activation
ls -la ~/.claude/skills/
```

After running the install script, all skills will be available to Claude Code.

---

## What's Included

### Skills (49 total)

Skills are auto-invoked capabilities that Claude uses when relevant to the task. Located in `claude/skills/`.

**Marketing & Growth:**
- ab-test-setup: A/B testing and experimentation
- analytics-tracking: Analytics implementation
- competitor-alternatives: Competitive analysis
- content-strategy: Content planning
- copywriting: Copy creation and improvement
- email-sequence: Email campaign design
- form-cro: Form conversion optimization
- free-tool-strategy: Free tool marketing
- launch-strategy: Product launch planning
- page-cro: Landing page optimization
- pricing-strategy: Pricing design
- product-hunt-launch: Product Hunt campaigns
- retention-strategy: User retention
- social-media-post: Social content creation
- viral-mechanics: Viral growth patterns

**Product & Design:**
- building-native-ui: Native UI development
- frontend-design: UI/UX design
- ios-simulator-skill: iOS simulator management
- laravel-inertia-react-structure: Laravel + Inertia + React architecture
- marketing-ideas: Marketing brainstorming
- mockup-to-app: Design to code conversion
- native-ux-patterns: Native UX patterns
- onboarding-ux: User onboarding flows
- react-components: React component patterns
- swiftui-components: SwiftUI components

**Content & Writing:**
- copy-editing: Content editing
- twitter-insights: Tweet analysis
- video-hooks: Video opening strategies
- x-thread: Twitter thread creation

**Development Tools:**
- agent-browser: Browser automation
- context7-auto-research: Automated research
- convert-github-issue-to-discussion: GitHub workflow
- fix-github-issue: Issue resolution
- flare: Error tracking (Flare integration)
- phpunit-integration-test-writing: PHPUnit test writing
- ray-skill: Ray debugging tool
- readability: Code readability analysis
- screenshot-to-api-requests: Visual to API conversion

**Business & Strategy:**
- ai-wrapper-assessment: AI product evaluation
- market-positioning: Positioning strategy
- persona-analysis: User persona development
- problem-value-map: Problem/value mapping
- value-prop-framework: Value proposition design

### Agents (2 total)

Agents are AI personas for complex task delegation. Located in `claude/agents/`.

**task-planner** (task-planner.md:1):
- Breaks down complex tasks into actionable steps
- Creates structured implementation plans
- Considers dependencies and sequencing
- Model: Opus, Color: Blue

**laravel-debugger** (laravel-debugger.md:1):
- Laravel-specific debugging assistance
- Analyzes errors and suggests fixes
- Model: Haiku, Color: Red

### Configuration Files

**.claude.json** (project-level, committed):
- Project-specific permissions
- Effort level: high
- Status line configuration
- Auto-loaded for this project

**.claude.local.json** (local overrides, gitignored):
- Machine-specific settings
- Personal preference overrides
- Template with examples included

**settings.json** (symlinked to ~/.claude/settings.json):
- Your global Claude Code settings
- Permissions, plugins, status line
- Already configured in your dotfiles

### Hooks

Located in `.claude/hooks/`:

**session-start.sh**:
- Runs when Claude Code session starts
- Detects active shell (Fish/ZSH)
- Reports configuration status
- Shows active skill count

**pre-tool-use.sh**:
- Validates operations before execution
- Enforces topic-centric pattern
- Warns about convention violations
- Non-blocking (warnings only)

### Status Line

**statusline.sh** (claude/statusline.sh:1):
- Custom status line for Claude Code
- Shows current context
- Referenced in settings.json

---

## Architecture

### Skill Structure

Skills are **directories**, not simple files:

```
claude/skills/ab-test-setup/
├── SKILL.md              # Main definition (YAML + content)
├── references/           # Supporting docs
│   ├── sample-size-guide.md
│   └── test-templates.md
├── scripts/              # Helper scripts
└── templates/            # File templates
```

**Key points:**
- Skills are auto-invoked by Claude when relevant
- Each skill has YAML frontmatter (name, version, description)
- Can include references, scripts, and templates
- Must be symlinked to ~/.claude/skills/ to be active

### Configuration Hierarchy

Claude Code reads config in this order (later overrides earlier):

1. `~/.claude/settings.json` (user-level, global)
2. `.claude.json` (project-level, this repo)
3. `.claude.local.json` (local overrides, gitignored)

**Use cases:**
- **User-level**: Personal preferences (editor, themes)
- **Project-level**: Repo-specific settings (permissions, effort)
- **Local-level**: Machine-specific overrides

---

## Installation & Activation

### Automatic Installation

The install script runs automatically when you execute `script/install`:

```bash
cd ~/.dotfiles
script/install

# Output includes:
› Running claude/install.sh
  [ .. ] Setting up Claude Code directories
  [ OK ] Claude directories created
  [ OK ] Settings linked
  [ OK ] Linked 49 public skills
  [ OK ] Linked 2 agents
  [ OK ] Statusline script linked

  Skills active: 49
  Agents active: 2
```

### Manual Installation

```bash
# Run Claude install script directly
./claude/install.sh
```

### Verification

```bash
# Check active skills
ls -la ~/.claude/skills/ | wc -l
# Should show 49 (or 53 with your existing 4)

# Check active agents
ls -la ~/.claude/agents/
# Should show 2 (task-planner.md, laravel-debugger.md)

# Check settings
cat ~/.claude/settings.json

# Test hooks (start new Claude session)
# Should see session-start.sh output
```

---

## Two-Repository Pattern (Optional)

For private/work-specific skills:

### Setup Private Skills Repo

1. **Create private repository:**
   ```bash
   mkdir -p ~/code/dotfiles-private/claude/skills
   cd ~/code/dotfiles-private
   git init
   ```

2. **Add private skills:**
   ```bash
   mkdir -p claude/skills/work-skill
   echo "Private work skill" > claude/skills/work-skill/SKILL.md
   git add . && git commit -m "Add work skill"
   git remote add origin YOUR_PRIVATE_REPO_URL
   git push -u origin main
   ```

3. **Configure install script:**
   ```bash
   # Edit claude/install.sh
   PRIVATE_REPO_URL="YOUR_PRIVATE_REPO_URL"
   ```

4. **Run installer:**
   ```bash
   ./claude/install.sh
   # Answer 'y' when prompted about private repo
   ```

### Directory Structure

```
~/.dotfiles/claude/skills/              # Public (49 skills)
~/.dotfiles-private/claude/skills/      # Private (your count)
~/.claude/skills/                        # Active (symlinks to both)
```

---

## Adding New Skills

### Create Public Skill

```bash
# Create skill directory
mkdir -p claude/skills/my-new-skill

# Create SKILL.md with frontmatter
cat > claude/skills/my-new-skill/SKILL.md << 'EOF'
---
name: my-new-skill
version: 1.0.0
description: Brief description of what this skill does
---

# My New Skill

Detailed content explaining what Claude should know and how to use this skill...

## When to Use

- Use case 1
- Use case 2

## Examples

Example content here...
EOF

# Commit to repo
git add claude/skills/my-new-skill
git commit -m "Add my-new-skill"

# Activate
./claude/install.sh
```

### Create Private Skill

```bash
# Create in private repo
mkdir -p ~/.dotfiles-private/claude/skills/private-skill
echo "Private skill content..." > ~/.dotfiles-private/claude/skills/private-skill/SKILL.md

# Commit to private repo
git -C ~/.dotfiles-private add claude/skills/private-skill
git -C ~/.dotfiles-private commit -m "Add private skill"
git -C ~/.dotfiles-private push

# Activate
./claude/install.sh
```

---

## Skills vs Commands vs Agents

### Skill (Auto-invoked)
- **What**: Knowledge base with specialized expertise
- **Location**: `~/.claude/skills/` (directories with SKILL.md)
- **Invocation**: Automatic (when relevant)
- **Example**: `ab-test-setup` activates when you mention A/B testing
- **This repo**: 49 skills

### Command (User-invoked)
- **What**: Slash command with prompt template
- **Location**: `~/.claude/commands/` (simple .md files)
- **Invocation**: Manual (`/command-name`)
- **Example**: `/commit` to create git commit
- **This repo**: None currently

### Agent (Task delegation)
- **What**: AI persona for complex multi-step work
- **Location**: `~/.claude/agents/` (.md files with YAML)
- **Invocation**: Via Task tool
- **Example**: `task-planner` for breaking down features
- **This repo**: 2 agents (task-planner, laravel-debugger)

---

## Hooks Reference

### Available Hooks

- **SessionStart**: When session begins
- **PreToolUse**: Before tool execution
- **PostToolUse**: After tool execution
- **UserPromptSubmit**: When user submits input

### Configured Hooks

**session-start.sh** (.claude/hooks/session-start.sh:1):
```bash
# Detects shell (Fish/ZSH)
# Shows config status
# Counts active skills
```

**pre-tool-use.sh** (.claude/hooks/pre-tool-use.sh:1):
```bash
# Validates file paths
# Enforces topic-centric pattern
# Warns about convention violations
```

### Hook Behavior

- Hooks are **optional** (script continues if hook fails)
- Hooks are **non-blocking** (warnings only, no errors)
- Hooks run **automatically** when enabled

---

## Troubleshooting

### Skills not activating

```bash
# Check if skills directory exists
ls ~/.claude/skills/

# Re-run installer
./claude/install.sh

# Check symlinks
ls -la ~/.claude/skills/ | grep ab-test
```

### Settings not loading

```bash
# Check settings file
cat ~/.claude/settings.json

# Check project config
cat .claude.json

# Check local overrides
cat .claude.local.json
```

### Hooks not running

```bash
# Check hook files exist
ls -la .claude/hooks/

# Check executable permissions
chmod +x .claude/hooks/*.sh

# Test hook manually
./.claude/hooks/session-start.sh
```

### Agents not available

```bash
# Check agents directory
ls -la ~/.claude/agents/

# Re-run installer
./claude/install.sh

# Check symlinks
ls -la ~/.claude/agents/task-planner.md
```

---

## Maintenance

### Update Skills

```bash
# Pull latest from dotfiles
cd ~/.dotfiles
git pull

# Re-run installer (updates symlinks)
./claude/install.sh
```

### Update Private Skills

```bash
# Pull private repo
cd ~/.dotfiles-private
git pull

# Re-run installer
cd ~/.dotfiles
./claude/install.sh
```

### Remove Skill

```bash
# Remove from repo
rm -rf claude/skills/unwanted-skill
git commit -am "Remove unwanted skill"

# Remove symlink
rm ~/.claude/skills/unwanted-skill
```

---

## Configuration Examples

### .claude.json (Project-level)

```json
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(brew:*)"
    ],
    "defaultMode": "ask"
  },
  "effortLevel": "high"
}
```

### .claude.local.json (Local overrides)

```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  },
  "customShell": "fish"
}
```

---

## Resources

- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code
- **iOS Development Guide**: example/claude-code-ios-dev-guide/README.md
- **Dotfiles Guide**: CLAUDE.md

---

## Current Status

Based on your setup:

- ✓ 49 skills in `claude/skills/`
- ✓ 2 agents in `claude/agents/`
- ✓ Configuration hierarchy created
- ✓ Hooks implemented
- ✓ Install script ready
- ✓ Enhanced CLAUDE.md

**Next steps:**
1. Run `./claude/install.sh` to activate all skills
2. Test hooks by starting new Claude session
3. (Optional) Set up private skills repository
