# Machine Setup

This directory contains everything needed for initial machine provisioning and setup.

## Contents

- **Brewfile** - Homebrew packages and casks to install
- **bootstrap.sh** - Initial setup script (git config, symlinks)
- **install.sh** - Main installation script (runs all installers)
- **macos/** - macOS-specific configuration
  - `set-defaults.sh` - System preferences and defaults
  - `set-hostname.sh` - Set computer hostname
- **scripts/** - Additional installation and setup scripts

## Quick Start

### First Time Setup

```bash
# Clone dotfiles to ~/.dotfiles
git clone YOUR_REPO_URL ~/.dotfiles
cd ~/.dotfiles

# Run bootstrap (creates symlinks, configures git)
./machine-setup/bootstrap.sh

# Run full install (installs packages, runs topic installers)
./machine-setup/install.sh
```

### What bootstrap.sh Does

1. Creates necessary directories
2. Sets up git configuration (from git/gitconfig.symlink)
3. Creates symlinks for all `.symlink` files
4. Prompts for user information (name, email)
5. Sets up shell preferences

### What install.sh Does

1. Runs Homebrew installation (if on macOS)
2. Installs packages from Brewfile
3. Runs all topic-specific `install.sh` scripts
4. Sets up Fish shell (default)
5. Optionally sets up ZSH shell
6. Runs AI tools setup (claude/install.sh)

## macOS Configuration

### Set System Defaults

```bash
# Apply all macOS system preferences
./machine-setup/macos/set-defaults.sh
```

This configures:
- Keyboard settings (fast key repeat)
- Finder preferences (show hidden files, extensions)
- Dock settings (position, size, autohide)
- Screenshots (location, format)
- And much more...

### Set Hostname

```bash
# Set computer name
./machine-setup/macos/set-hostname.sh
```

## Maintenance

### Update Everything

```bash
# Update dotfiles, packages, and configurations
dot
```

The `dot` command (from config/bin/dot) does:
1. Pulls latest dotfiles from git
2. Updates Homebrew and packages
3. Re-runs all install.sh scripts
4. Updates Claude Code skills

### Update Specific Components

```bash
# Just update Homebrew packages
brew bundle --file=machine-setup/Brewfile

# Just re-run bootstrap (update symlinks)
./machine-setup/bootstrap.sh

# Just update AI tools
./ai/claude/install.sh
```

## Customization

### Adding Packages

Edit `Brewfile` and add your packages:

```ruby
# CLI tools
brew "ripgrep"
brew "fd"

# Applications
cask "visual-studio-code"
cask "iterm2"
```

Then run:
```bash
brew bundle --file=machine-setup/Brewfile
```

### Adding macOS Defaults

Edit `macos/set-defaults.sh` and add your preferences:

```bash
# Example: Enable dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
```

## Troubleshooting

### Symlinks Not Created

```bash
# Check if symlinks exist
ls -la ~/ | grep "dotfiles"

# Re-run bootstrap
./machine-setup/bootstrap.sh
```

### Brewfile Install Fails

```bash
# Update Homebrew
brew update

# Try installing individually
brew install package-name
```

### Shell Not Switching

```bash
# Fish shell
chsh -s $(which fish)

# ZSH shell
chsh -s $(which zsh)

# Verify
echo $SHELL
```

## Files Reference

| File | Purpose | When to Run |
|------|---------|-------------|
| bootstrap.sh | Initial setup, symlinks | First install, after adding new symlinks |
| install.sh | Install everything | First install, after major changes |
| Brewfile | Package definitions | After adding packages |
| macos/set-defaults.sh | System preferences | First install, after macOS updates |
| macos/set-hostname.sh | Set computer name | First install, when changing hostname |

## Next Steps

After running machine-setup:

1. **Configure shell** - See `config/README.md`
2. **Set up AI tools** - See `ai/README.md`
3. **Customize configs** - Edit files in `config/`
4. **Add private configs** - Create `~/.localrc` for sensitive data
