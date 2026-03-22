# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a topic-centric dotfiles repository for macOS, originally forked from [holman/dotfiles](https://github.com/holman/dotfiles). The dotfiles are organized by topic (git, system, etc.) rather than having one monolithic configuration file. The repository uses **Fish** shell as the default, with optional **ZSH** support. The repository is designed to be easily forked and customized.

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
- **`claude/skills/`** - Claude Code skills (slash commands), supports public + private skills

## Common Commands

### Initial Setup
```bash
# Clone and bootstrap (creates symlinks, configures git, installs dependencies on macOS)
git clone https://github.com/holman/dotfiles.git ~/.dotfiles
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

## Development Workflow

### Adding a New Topic

1. Create a new directory: `mkdir newtopic/`
2. Add files with appropriate extensions:
   - **For ZSH**: `newtopic/aliases.zsh`, `newtopic/path.zsh`, etc.
   - **For Fish**: `newtopic/aliases.fish`, `newtopic/path.fish`, etc.
   - `newtopic/config.symlink` - Config file to symlink to `~/.config`
   - `newtopic/install.sh` - Installation script

### Modifying Configuration

- **ZSH config**: Edit files in topic directories (e.g., `git/aliases.zsh`, `system/env.zsh`)
- **Fish config**: Edit files in topic directories (e.g., `git/aliases.fish`, `system/path.fish`)
- **Symlinked dotfiles**: Edit `*.symlink` files (changes apply to `~/.filename`)
- **Packages**: Update `Brewfile` in root directory
- **macOS defaults**: Edit `macos/set-defaults.sh`

### Testing Changes

After modifying ZSH files:
- Restart your shell or run: `source ~/.zshrc`

After modifying fish configuration files:
- Restart your shell or run: `source ~/.config/fish/config.fish` (or use the `reload` alias)

After modifying symlinked files:
- Changes are immediate (symlinks point to repo files)

## Important Files

- **`zsh/zshrc.symlink`** - Main ZSH configuration, defines loading order
- **`fish/config.fish`** - Main Fish configuration, defines loading order and discovers topic files
- **`fish/install.sh`** - Fish configuration installer (creates config symlink)
- **`Brewfile`** - Homebrew dependencies (packages and casks)
- **`script/bootstrap`** - Initial setup script (git config, symlinks, dependencies)
- **`bin/dot`** - Maintenance script for updates
- **`git/gitconfig.symlink`** - Git configuration (uses `gitconfig.local.symlink` for personal settings)

## Configuration Philosophy

- Keep configurations versioned and organized by topic
- Use `~/.localrc` (ZSH) or `~/.localrc.fish` (Fish) for sensitive/local-only environment variables (not tracked in git)
- Personal git settings go in `git/gitconfig.local.symlink` (created during bootstrap)
- The system is designed to be forked - remove what you don't need, extend what you do

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

## Claude Code Skills Management

Claude Code skills (slash commands) are managed with a two-repository approach:

**Public skills** (in this repo):
- Located in `claude/skills/`
- General-purpose, shareable skills
- Tracked in the dotfiles repository

**Private skills** (separate repo):
- Located in `~/.dotfiles-private/claude/skills/`
- Personal, work-specific, or sensitive skills
- Tracked in a separate private repository

### Setup

1. **Install public skills** (runs automatically with `script/install`):
   ```bash
   ./claude/install.sh
   ```

2. **Set up private skills** (optional):
   - Create a private repository with structure: `dotfiles-private/claude/skills/`
   - Edit `claude/install.sh` and set `PRIVATE_REPO_URL`
   - Run `./claude/install.sh` and answer `y` when prompted

3. **Result**: Both public and private skills are symlinked to `~/.claude/commands/`

### Adding New Skills

**Public skill**:
```bash
# Create skill in dotfiles
echo "# My Skill" > claude/skills/my-skill.md
git add claude/skills/my-skill.md
git commit -m "Add my-skill"
./claude/install.sh
```

**Private skill**:
```bash
# Create skill in private repo
echo "# Private Skill" > ~/.dotfiles-private/claude/skills/private.md
git -C ~/.dotfiles-private add claude/skills/private.md
git -C ~/.dotfiles-private commit -m "Add private skill"
git -C ~/.dotfiles-private push
./claude/install.sh
```

See `claude/README.md` for detailed documentation.
