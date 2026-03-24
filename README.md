# dotfiles

Your dotfiles are how you personalize your system. These are mine.

This repository uses a unix/mac split structure to support both macOS and Linux, with cross-platform Homebrew installation and configuration management.

## Structure

The repository is organized into three main directories:

### machine-setup/

Machine setup and installation scripts organized by platform.

- **machine-setup/** - Installation and setup scripts
  - `bootstrap.sh` - Main entry point for setting up a new machine
  - **machine-setup/unix/** - Cross-platform installation scripts
    - `install.sh` - Install dependencies and packages
    - `install-homebrew.sh` - Install Homebrew (works on macOS and Linux)
    - `Brewfile` - Package definitions for Homebrew
    - `install-fish.sh` - Fish shell setup with Fisher and Bass
    - `install-zsh.sh` - ZSH shell setup (optional)

- **machine-setup/mac/** - macOS-specific system setup
  - `set-defaults.sh` - macOS system preferences and defaults
  - `set-hostname.sh` - macOS hostname configuration

### config/

Application configuration files organized by platform.

- **config/unix/** - Cross-platform configurations
  - `bin/` - Utilities added to `$PATH`
  - `git/` - Git configuration and aliases
  - `zsh/` - ZSH configuration
  - `vim/` - Vim configuration
  - `functions/` - Shell functions
  - `system/` - System aliases and settings
  - `atuin/`, `docker/`, `editors/` - Tool-specific configs

- **config/mac/** - macOS-specific configurations
  - `homebrew/` - Homebrew-specific settings
  - `xcode/` - Xcode configuration

### ai/

AI coding assistant configuration using layered architecture.

**Layered Architecture:**
- **Layer 1**: Claude Code Core (base system)
- **Layer 2**: Everything Claude Code Plugin (60 commands, 28 agents, 119 skills)
- **Layer 3**: Personal configs (CLAUDE.md, agents, skills, statusline)

**Structure:**
- `.claude/CLAUDE.md` - Personal preferences and rules
- `.claude/settings.json` - Security, statusline, permissions
- `.claude/agents/` - 4 custom Laravel-focused agents
- `.claude/skills/` - ~49 domain-specific skills
- `.claude/rules/` - Laravel PHP guidelines
- `scripts/statusline.sh` - Custom statusline (repo + context %)
- `README.md` - Full AI setup documentation

**Installation:**
```bash
machine-setup/unix/install-ai.sh
```

This installs ECC plugin (community toolkit) + symlinks personal configs from `ai/.claude/`

## Components

Special files in the hierarchy:

- **config/unix/bin/**: Utilities added to your `$PATH`
- **\*.zsh**: Files loaded into ZSH environment
- **path.zsh**: Loaded first to setup `$PATH`
- **completion.zsh**: Loaded last for autocomplete
- **\*.symlink**: Files symlinked to `$HOME` (e.g., `gitconfig.symlink` → `~/.gitconfig`)
- **install.sh**: Executed during installation

## Installation

### First Time Setup (New Machine)

**IMPORTANT: Backup your machine first!**

Before running any setup scripts, create a Time Machine backup (macOS) or full system backup:

**macOS Time Machine:**
1. Connect an external drive
2. System Settings → General → Time Machine
3. Click "Back Up Now"
4. Wait for backup to complete

**Linux:**
- Use `rsync`, `timeshift`, or your preferred backup tool
- Backup `/home/` and important system configs

Having a full system backup ensures you can restore everything if needed.

---

**Step 1: Setup SSH keys**

On a brand new machine, you need to set up SSH keys first:

```sh
# Download and run pre-bootstrap to setup SSH
curl -fsSL https://raw.githubusercontent.com/yourusername/dotfiles/main/machine-setup/unix/pre-bootstrap.sh | bash
```

Or if you prefer to clone with HTTPS first:

```sh
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
machine-setup/unix/pre-bootstrap.sh
```

The pre-bootstrap script will:
- Generate SSH keys if they don't exist
- Add keys to ssh-agent and macOS keychain
- Display your public key and open GitHub settings
- Wait for you to add the key to GitHub
- Test the SSH connection

**Step 2: Run main bootstrap**

After SSH is set up and Time Machine backup is complete:

```sh
git clone git@github.com:yourusername/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles
sh machine-setup/bootstrap.sh
```

The bootstrap will:
- Prompt you to choose a shell (Fish, ZSH, or skip)
- Or you can specify: `--shell fish`, `--shell zsh`, `--shell skip`

**With shell choice and optional macOS setup:**
```sh
# Fish shell with all macOS setup (recommended for new machines)
machine-setup/bootstrap.sh --shell fish --all

# ZSH shell without macOS setup
machine-setup/bootstrap.sh --shell zsh

# Or run individual components:
machine-setup/bootstrap.sh --shell fish --set-defaults  # Apply macOS system defaults
machine-setup/bootstrap.sh --shell zsh --set-hostname   # Set macOS hostname
machine-setup/bootstrap.sh --shell skip -d -n           # No shell, both macOS setups
```

This will:
1. Prompt you to choose a shell (Fish or ZSH) unless `--shell` is specified
2. Configure git with your name and email
3. Create symlinks for dotfiles (`.gitconfig`, `.zshrc` or `.config/fish/config.fish`, etc.)
4. Create `~/.dotfiles` symlink pointing to your dotfiles directory
5. Symlink Ghostty configuration to `~/.config/ghostty/`
6. Install Homebrew (on macOS or Linux)
7. Install packages from Brewfile
8. Setup chosen shell (Fish with Fisher and Bass, or ZSH)
9. Set Ghostty as default terminal (macOS only, if Fish was chosen)
10. Run platform-specific installers
11. Optionally apply macOS defaults (with `-d` or `--set-defaults` flag)
12. Optionally set macOS hostname (with `-n` or `--set-hostname` flag)

**AI Setup (Optional):**
After bootstrap, install AI coding assistant configuration:
```bash
machine-setup/unix/install-ai.sh
```

## Updating

To update dependencies and packages:

```sh
cd ~/.dotfiles
machine-setup/unix/install.sh
```

To update dotfiles repository:

```sh
cd ~/.dotfiles
git pull
```

## Cross-Platform Support

This setup works on both **macOS** and **Linux**:

- **Homebrew** is used on both platforms for package management
- Most configurations are in `config/unix/` and work everywhere
- Platform-specific configs go in `config/mac/` or machine-specific setup scripts
- Bootstrap script automatically detects the platform

## Shells

You choose which shell to install during bootstrap (or skip shell installation):

- **Fish** - Modern, user-friendly shell with great defaults
  - Installed with Fisher plugin manager and Bass for bash compatibility
  - Fish-native configs in `*.fish` files
  - Set as default shell and Ghostty configured to use it

- **ZSH** - Powerful, customizable shell
  - Configured with topic-centric approach
  - Uses `*.zsh` files for configuration

- **Skip** - No shell installation
  - Just sets up dotfiles and configurations
  - Use your existing shell setup

## Customization

Fork this repository and customize:

1. Edit `machine-setup/unix/Brewfile` to add/remove packages
2. Add your own topic directories in `config/unix/`
3. Create macOS-specific configs in `config/mac/`
4. Modify `machine-setup/mac/set-defaults.sh` for macOS preferences
5. Update git configuration in `config/unix/git/`

## Philosophy

Everything is organized by topic areas. Adding a new feature means creating a directory (e.g., `config/unix/ruby/`) and adding files:

- `*.zsh` files get loaded into your shell
- `*.symlink` files get symlinked to `$HOME`
- `install.sh` scripts run during installation

This keeps configuration modular and easy to manage.

## Credits

Originally forked from [holman/dotfiles](https://github.com/holman/dotfiles) and restructured for cross-platform unix/mac usage with Homebrew.
