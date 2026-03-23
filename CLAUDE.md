# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Memory Imports

```markdown
<!-- Import all topic-specific documentation -->
{{#each topics}}
@import ./{{this}}/README.md
{{/each}}

<!-- Import Claude-specific instructions -->
@import ./claude/CLAUDE.md
```

## Overview

This is a topic-centric dotfiles repository for macOS, originally forked from [holman/dotfiles](https://github.com/holman/dotfiles). The dotfiles are organized by topic (git, system, etc.) rather than having one monolithic configuration file. The repository uses **Fish** shell as the default, with optional **ZSH** support. The repository is designed to be easily forked and customized.

## Configuration Hierarchy

Claude Code reads configuration in this order (later files override earlier ones):

1. **`~/.claude/settings.json`** (User-level, global defaults)
2. **`.claude.json`** (Project-level, this repo)
3. **`.claude.local.json`** (Local overrides, gitignored)

This means:
- Set your personal preferences in `~/.claude/settings.json`
- Project-specific settings live in `.claude.json` (committed to repo)
- Machine-specific overrides go in `.claude.local.json` (not committed)

### Configuration Files in This Repo

**`.claude.json`** (project-level, committed):
- Project-specific permissions
- Effort level preferences
- Status line configuration

**`.claude.local.json`** (local overrides, gitignored):
- Machine-specific settings
- Personal preferences that differ from project defaults

## Hooks System

Hooks are shell scripts that run at specific lifecycle events. Located in `.claude/hooks/`:

**`session-start.sh`** (SessionStart hook):
- Runs when a new Claude Code session starts
- Detects active shell (Fish, ZSH, Bash)
- Reports configuration status
- Counts active skills

**`pre-tool-use.sh`** (PreToolUse hook):
- Validates operations before execution
- Enforces topic-centric pattern for new files
- Warns if files don't follow conventions
- Does NOT block operations, only warns

To enable hooks in your session, Claude Code will automatically discover and use them from `.claude/hooks/`.

## Effort Level & Thinking

This project uses **high effort level** by default. When working on complex tasks:

- Use **"think"** for standard problems
- Use **"think hard"** for complex architecture decisions
- Use **"ultrathink"** for deep analysis and planning

Extended thinking is enabled in project settings.

---

## Architecture

### Topic-based Organization

Everything is organized around topic areas (git, system, homebrew, macos, etc.). Each topic directory can contain:

- **`*.zsh`** - Auto-loaded into ZSH shell environment
- **`*.fish`** - Auto-loaded into Fish shell environment
- **`path.zsh`** / **`path.fish`** - Loaded first, sets up `$PATH`
- **`env.fish`** - Loaded second in Fish, sets environment variables
- **`completion.zsh`** - Loaded last in ZSH, sets up shell completion
- **`init.fish`** - Loaded last in Fish, for initialization (like atuin)
- **`*.symlink`** - Symlinked to `$HOME` (without `.symlink` extension)
- **`install.sh`** - Executed during installation (uses `.sh` to avoid auto-loading)

### Shell Configurations

**Fish shell is the default**, with optional ZSH support. Both follow the same topic-centric pattern.

#### ZSH Configuration

The `zsh/zshrc.symlink` orchestrates loading in this order:
1. All `path.zsh` files first
2. All other `*.zsh` files (except completion)
3. Initialize shell completion (`compinit`)
4. All `completion.zsh` files last

This ensures PATH is set before other scripts run, and completions are registered after the completion system is initialized.

#### Fish Shell Configuration

The `fish/config.fish` orchestrates loading in this order:
1. All `path.fish` files first
2. All `env.fish` files second
3. All other `*.fish` files (aliases, etc.)
4. All `init.fish` files last

This mirrors the ZSH loading pattern. Fish configuration files are distributed across topic directories (e.g., `git/aliases.fish`, `system/path.fish`, `atuin/init.fish`).

### Key Directories

- **`bin/`** - Utilities added to `$PATH` (git helpers, system tools, custom scripts)
- **`script/`** - Installation and setup scripts
- **`functions/`** - Shell function definitions and completions
- **`macos/`** - macOS-specific defaults and configuration
- **`claude/skills/`** - Claude Code skills (49 skills available)
- **`claude/agents/`** - Agent definitions (personas for task delegation)

### Functions vs Bin

**`functions/`**:
- Shell functions that are sourced into the shell
- Can modify the current shell environment (cd, export, etc.)
- Run in the same process as the shell

**`bin/`**:
- Executable scripts run in subshells
- Cannot modify the parent shell environment
- Standalone utilities

---

## Common Commands

### Initial Setup
```bash
# Clone and bootstrap (creates symlinks, configures git, installs dependencies on macOS)
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

### Maintenance
```bash
# Update everything: pull latest, set macOS defaults, upgrade Homebrew, run installers
dot

# Edit dotfiles in your editor
dot -e

# Install/update dependencies (runs brew bundle + all install.sh scripts)
script/install
```

### Claude Skills Management
```bash
# Activate all skills (symlinks claude/skills/* to ~/.claude/skills/)
./claude/install.sh

# Check active skills
ls -la ~/.claude/skills/
```

### macOS Configuration
```bash
# Apply macOS defaults (key repeat, Finder settings, etc.)
macos/set-defaults.sh

# Set macOS hostname
macos/set-hostname.sh
```

### Package Management
```bash
# Install packages from Brewfile
brew bundle

# Update specific package definitions in Brewfile
# Then run: brew bundle
```

---

## Development Workflow

### Adding a New Topic

1. Create a new directory: `mkdir newtopic/`
2. Add files with appropriate extensions:
   - **For ZSH**: `newtopic/aliases.zsh`, `newtopic/path.zsh`, etc.
   - **For Fish**: `newtopic/aliases.fish`, `newtopic/path.fish`, etc.
   - `newtopic/config.symlink` - Config file to symlink to `~/.config`
   - `newtopic/install.sh` - Installation script

### Modifying Configuration

- **ZSH config**: Edit files in topic directories (e.g., `git/aliases.zsh` at git/aliases.zsh:1)
- **Fish config**: Edit files in topic directories (e.g., `git/aliases.fish` at git/aliases.fish:1)
- **Symlinked dotfiles**: Edit `*.symlink` files (changes apply to `~/.filename`)
- **Packages**: Update `Brewfile` in root directory
- **macOS defaults**: Edit `macos/set-defaults.sh` at macos/set-defaults.sh:1

### Testing Changes

After modifying ZSH files:
- Restart your shell or run: `source ~/.zshrc`

After modifying fish configuration files:
- Restart your shell or run: `source ~/.config/fish/config.fish` (or use the `reload` alias)

After modifying symlinked files:
- Changes are immediate (symlinks point to repo files)

---

## Important Files

- **`zsh/zshrc.symlink`** (zsh/zshrc.symlink:1) - Main ZSH configuration, defines loading order
- **`fish/config.fish`** (fish/config.fish:1) - Main Fish configuration, defines loading order and discovers topic files
- **`fish/install.sh`** (fish/install.sh:1) - Fish configuration installer (creates config symlink)
- **`Brewfile`** (Brewfile:1) - Homebrew dependencies (packages and casks)
- **`script/bootstrap`** (script/bootstrap:1) - Initial setup script (git config, symlinks, dependencies)
- **`bin/dot`** (bin/dot:1) - Maintenance script for updates
- **`git/gitconfig.symlink`** (git/gitconfig.symlink:1) - Git configuration (uses `gitconfig.local.symlink` for personal settings)
- **`claude/install.sh`** (claude/install.sh:1) - Skills activation script
- **`.claude.json`** (.claude.json:1) - Project-level Claude Code configuration
- **`.claude.local.json`** (.claude.local.json:1) - Local Claude Code overrides (gitignored)

---

## Configuration Philosophy

- Keep configurations versioned and organized by topic
- Use `~/.localrc` (ZSH) or `~/.localrc.fish` (Fish) for sensitive/local-only environment variables (not tracked in git)
- Personal git settings go in `git/gitconfig.local.symlink` (created during bootstrap)
- The system is designed to be forked: remove what you don't need, extend what you do

---

## Shell Configuration

**Fish is the default shell** and will be set up automatically when you run `script/bootstrap` or `script/install`.

**Shell setup:**
- **Fish** (default): Installed automatically if fish is present
  - Uses `~/.config/fish/config.fish` (symlinked by `fish/install.sh`)
  - To set as default: `chsh -s $(which fish)`
- **ZSH** (optional): Only set up if you confirm during install
  - Uses `~/.zshrc` (symlinked from `zsh/zshrc.symlink` by `script/bootstrap`)
  - During `script/install`, you'll be prompted: "Do you want to set up ZSH shell configuration?"
  - Answer `y` to enable ZSH support, `n` to skip
  - To use: `chsh -s $(which zsh)`

**Installation flow:**
```bash
script/bootstrap  # or script/install
# ...
› Running fish/install.sh
  Fish configuration symlinked (default shell)

› Running zsh/install.sh
  Do you want to set up ZSH shell configuration? [y/N]
```

**Note:** Both shells follow the same topic-centric pattern. Configuration files are distributed across topic directories (e.g., `git/aliases.zsh` and `git/aliases.fish` live side-by-side in the `git/` directory).

---

## Claude Code Skills Management

This repository contains **49 skills** in `claude/skills/`. Skills are directories containing `SKILL.md` files that provide Claude with specialized knowledge and capabilities.

### Skill Architecture

**Skills are directories**, not simple markdown files. Structure:
```
claude/skills/ab-test-setup/
├── SKILL.md              # Main skill definition (YAML frontmatter + content)
├── references/           # Supporting documentation
│   ├── sample-size-guide.md
│   └── test-templates.md
├── scripts/              # Helper scripts (if needed)
└── templates/            # File templates (if needed)
```

Skills are **auto-invoked** by Claude when relevant to the task (unlike slash commands, which are user-invoked).

### Available Skills

The repository includes 49 skills across categories:
- Marketing: ab-test-setup, analytics-tracking, competitor-alternatives, content-strategy, copywriting, email-sequence
- Product: building-native-ui, form-cro, free-tool-strategy, frontend-design, launch-strategy
- Development: laravel-inertia-react-structure, ios-simulator-skill, agent-browser
- Content: copy-editing, page-cro, social-media-post
- Tools: context7-auto-research, convert-github-issue-to-discussion, fix-github-issue

See `claude/skills/` directory for complete list.

### Two-Repository Approach

**Public skills** (in this repo):
- Located in `claude/skills/`
- General-purpose, shareable skills
- Committed to version control

**Private skills** (optional, separate repo):
- Located in `~/.dotfiles-private/claude/skills/`
- Personal, work-specific, or sensitive skills
- Tracked in separate private repository

### Activation

Skills must be symlinked to `~/.claude/skills/` to be active:

```bash
# Activate all skills
./claude/install.sh

# Verify activation
ls -la ~/.claude/skills/
```

The install script:
1. Creates `~/.claude/skills/` directory
2. Symlinks each skill directory from `claude/skills/` to `~/.claude/skills/`
3. Optionally handles private skills from `~/.dotfiles-private/`

### Setup Process

**1. Install public skills** (runs automatically with `script/install`):
```bash
./claude/install.sh
```

**2. Set up private skills** (optional):
- Create a private repository with structure: `dotfiles-private/claude/skills/`
- Edit `claude/install.sh` and set `PRIVATE_REPO_URL`
- Run `./claude/install.sh` and answer `y` when prompted

**3. Result**: Both public and private skills are symlinked to `~/.claude/skills/`

### Adding New Skills

**Public skill**:
```bash
# Create skill directory
mkdir -p claude/skills/my-skill
echo "---
name: my-skill
version: 1.0.0
description: Brief description
---

# My Skill

Skill content here...
" > claude/skills/my-skill/SKILL.md

git add claude/skills/my-skill
git commit -m "Add my-skill"
./claude/install.sh
```

**Private skill**:
```bash
# Create skill in private repo
mkdir -p ~/.dotfiles-private/claude/skills/private-skill
echo "Skill content" > ~/.dotfiles-private/claude/skills/private-skill/SKILL.md
git -C ~/.dotfiles-private add claude/skills/private-skill
git -C ~/.dotfiles-private commit -m "Add private skill"
git -C ~/.dotfiles-private push
./claude/install.sh
```

### Skill vs Command vs Agent

**Skill**: Auto-invoked capability
- Directory with `SKILL.md` file
- Claude automatically uses when relevant
- Located in `~/.claude/skills/`
- Example: `ab-test-setup` activates when user mentions A/B testing

**Command** (slash command): User-invoked prompt
- Simple `.md` file with prompt content
- User explicitly invokes with `/command-name`
- Located in `~/.claude/commands/`
- Example: `/commit` to create a git commit

**Agent**: AI persona for task delegation
- `.md` file with YAML frontmatter defining persona
- Used with Task tool for complex multi-step work
- Located in `~/.claude/agents/`
- Example: `task-planner` agent for breaking down complex tasks

This repo has both skills and agents configured.

---

## Git Configuration Pattern

Git uses a two-file pattern for public/private split:

**`git/gitconfig.symlink`** → `~/.gitconfig` (public settings):
- Aliases, colors, diff settings
- Committed to repository
- Includes reference to `~/.gitconfig.local`

**`git/gitconfig.local.symlink`** → `~/.gitconfig.local` (private info):
- User name and email
- Credential helper
- Created during `script/bootstrap` (prompted)
- **Not committed** (in `.gitignore`)

The bootstrap script creates `gitconfig.local.symlink` from `gitconfig.local.symlink.example` by prompting for your name and email.
