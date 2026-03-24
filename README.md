# dotfiles

Your dotfiles are how you personalize your system. These are mine.

This repository uses a unix/mac split structure to support both macOS and Linux, with cross-platform Homebrew installation and configuration management.

## Structure

The repository is organized into three main directories:

### machine-setup/

Machine setup and installation scripts organized by platform.

- **machine-setup/unix/** - Cross-platform installation scripts
  - `bootstrap.sh` - Main entry point for setting up a new machine
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

Claude Code configuration and skills (49 skills available).

- `.claude.json` - Project-level Claude Code settings
- `CLAUDE.md` - Documentation for Claude Code
- `skills/` - Claude Code skills directory
- `hooks/` - Claude Code hooks for automation

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

### Main Bootstrap

After SSH is set up, run the main bootstrap:

```sh
git clone git@github.com:yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
machine-setup/unix/bootstrap.sh
```

**With optional macOS setup:**
```sh
# Apply macOS system defaults (key repeat, Finder settings, etc.)
machine-setup/unix/bootstrap.sh --set-defaults

# Set macOS hostname
machine-setup/unix/bootstrap.sh --set-hostname

# Both
machine-setup/unix/bootstrap.sh -d -n
```

This will:
1. Initialize git submodules (Claude Code setup)
2. Configure git with your name and email
3. Create symlinks for dotfiles (`.gitconfig`, `.zshrc`, etc.)
4. Symlink Claude Code configuration to `~/.claude/`
5. Symlink Ghostty configuration to `~/.config/ghostty/`
6. Install Homebrew (on macOS or Linux)
7. Install packages from Brewfile
8. Setup Fish shell with Fisher and Bass (set as default)
9. Set Ghostty as default terminal (macOS only)
10. Optionally setup ZSH
11. Run platform-specific installers
12. Optionally apply macOS defaults (with `-d` flag)
13. Optionally set macOS hostname (with `-n` flag)

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

- **Fish** is the default shell (installed with Fisher plugin manager and Bass for bash compatibility)
- **ZSH** is optional (configured with topic-centric approach)
- Shell configs use `.zsh` files for ZSH (Fish uses Bass to run bash utilities)

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
