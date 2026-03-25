# AI Configuration

Personal AI coding assistant configuration using a layered architecture.

## Layered Architecture

```
┌─────────────────────────────────────────────┐
│ Layer 3: Personal Overrides                │  ← This directory
│ (CLAUDE.md, settings, agents, skills)      │
├─────────────────────────────────────────────┤
│ Layer 2: Everything Claude Code Plugin     │  ← Installed via /plugin
│ (60 commands, 28 agents, 119 skills)       │
├─────────────────────────────────────────────┤
│ Layer 1: Claude Code Core                  │  ← Base system
└─────────────────────────────────────────────┘
```

## Structure

```
ai/
├── .claude/                      # Personal configurations (Layer 3)
│   ├── CLAUDE.md                 # Personal preferences and coding standards
│   │                             # (C#, Go, Swift, Flutter, Kotlin, C++, Python)
│   ├── settings.json             # Security, statusline, permissions
│   ├── agents/                   # Your custom agents (empty by default)
│   ├── skills/                   # Your custom skills (empty by default)
│   │   └── SKILL_TEMPLATE.md    # Template for creating skills
│   └── rules/                    # Your custom rules (empty by default)
├── scripts/
│   └── statusline.sh             # Custom statusline (repo + context %)
├── README.md                     # This file
└── USAGE_GUIDE.md                # How to use ECC with your dev stack
```

## Installation

Run the AI setup script:

```bash
cd ~/Documents/dotfiles
machine-setup/unix/install-ai.sh
```

This will:
1. ✅ **Layer 1**: Verify Claude Code is installed
2. ✅ **Layer 2**: Install ECC plugin + rules
3. ✅ **Layer 3**: Symlink personal configs from this directory

## What Gets Installed

### Layer 2: ECC Plugin (Community)
- **60+ commands**: `/tdd`, `/plan`, `/code-review`, `/build-fix`, etc.
- **28 agents**: planner, code-reviewer, security-reviewer, etc.
- **119 skills**: TDD, security, patterns, testing, etc.
- **Hooks**: Auto-format, typecheck, tmux reminders, etc.
- **Rules**: Common + language-specific for your tech stack:
  - TypeScript/JavaScript
  - Python
  - Go
  - Swift
  - C#
  - Kotlin
  - Rust/C++

### Layer 3: Personal Configs (You)
- **CLAUDE.md**: Personal preferences + coding standards for:
  - C# / WPF Desktop Development
  - Go Development
  - Swift Development
  - Flutter / Dart
  - Kotlin
  - C++
  - Python
- **settings.json**: Security deny list, statusline, permissions
- **Custom agents**: Your domain-specific agents (add as needed)
- **Custom skills**: Your workflow-specific skills (add as needed)
- **Custom rules**: Your project-specific rules (add as needed)

## Usage

**See [USAGE_GUIDE.md](USAGE_GUIDE.md) for detailed examples of how to use ECC with each language in your stack.**

### Commands
```bash
# ECC commands (Layer 2) - namespaced
/everything-claude-code:plan "Add user authentication"
/everything-claude-code:tdd
/everything-claude-code:code-review

# Your custom agents/skills (Layer 3) - add as needed
# See SKILL_TEMPLATE.md for how to create custom skills
```

### Updating

**Update ECC plugin:**
```bash
claude <<EOF
/plugin update everything-claude-code@everything-claude-code
EOF
```

**Update personal configs:**
- Edit files in `dotfiles/ai/.claude/`
- Changes take effect immediately (symlinked)

**Update ECC rules:**
```bash
cd ~/Documents/PersonalProjects/setup/everything-claude-code
git pull
machine-setup/unix/install-ai.sh  # Re-run to update rules
```

## Customization

### Add New Personal Agent
```bash
# Create in dotfiles
vim ai/.claude/agents/my-agent.md

# Symlink will be created on next install-ai.sh run
# Or manually:
ln -sf ~/Documents/dotfiles/ai/.claude/agents/my-agent.md ~/.claude/agents/
```

### Add New Personal Skill

**Use the template:**
```bash
# See SKILL_TEMPLATE.md for structure and examples
cat ai/.claude/skills/SKILL_TEMPLATE.md

# Create your skill
mkdir -p ai/.claude/skills/wpf-mvvm-pattern
vim ai/.claude/skills/wpf-mvvm-pattern/SKILL.md

# Re-run install to symlink
machine-setup/unix/install-ai.sh

# Or manually symlink
ln -sf ~/Documents/dotfiles/ai/.claude/skills/wpf-mvvm-pattern ~/.claude/skills/
```

**Skill ideas for your stack:**
- `wpf-mvvm-pattern`, `go-error-handling`, `swift-async-await`
- `flutter-bloc-pattern`, `kotlin-coroutines`, `cpp-raii-pattern`
- `python-type-hints`

See `SKILL_TEMPLATE.md` for detailed examples and naming conventions.

### Modify Settings
```bash
# Edit in dotfiles
vim ai/.claude/settings.json

# Changes are immediate (symlinked to ~/.claude/settings.json)
```

## Philosophy

**Why Layered?**
1. **Separation**: ECC is community toolkit, personal configs are yours
2. **Updates**: `claude /plugin update` gets latest ECC
3. **Portability**: Bootstrap script works on any machine
4. **Lean dotfiles**: Only your customizations, not duplicating ECC

**What goes where?**
- **ECC (Layer 2)**: General-purpose, community-maintained
- **Personal (Layer 3)**: Your workflow, domain expertise, preferences

## Troubleshooting

**ECC commands not found:**
```bash
# Check plugin status
claude <<EOF
/plugin list
EOF

# Reinstall if needed
machine-setup/unix/install-ai.sh
```

**Personal configs not loaded:**
```bash
# Verify symlinks
ls -la ~/.claude/CLAUDE.md
ls -la ~/.claude/settings.json

# Recreate if broken
machine-setup/unix/install-ai.sh
```

**Statusline not showing:**
```bash
# Check script is executable
ls -la ~/.claude/statusline.sh

# Test manually
echo '{"workspace":{"current_dir":"/tmp"},"context_window":{"used_percentage":45}}' | ~/.claude/statusline.sh
```

## References

- **ECC Repository**: https://github.com/affaan-m/everything-claude-code
- **ECC Guides**:
  - [Shorthand Guide](https://x.com/affaanmustafa/status/2012378465664745795)
  - [Longform Guide](https://x.com/affaanmustafa/status/2014040193557471352)
  - [Security Guide](https://x.com/affaanmustafa/status/2033263813387223421)
