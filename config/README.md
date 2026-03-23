# Configuration

This directory contains all shell and tool configurations, organized by category.

## Structure

```
config/
├── shell/          # Shell configurations
│   ├── fish/       # Fish shell (default)
│   ├── zsh/        # ZSH shell (optional)
│   └── shared/     # Shared aliases and functions
├── tools/          # Tool-specific configurations
│   ├── atuin/      # Shell history sync
│   ├── docker/     # Docker aliases
│   ├── editors/    # Editor environment variables
│   ├── git/        # Git configuration
│   ├── homebrew/   # Homebrew paths
│   ├── vim/        # Vim configuration
│   └── xcode/      # Xcode aliases
├── system/         # System-wide settings
└── bin/            # Utility scripts
```

## Shell Configuration

### Fish Shell (Default)

Fish is the default shell in this setup. Configuration is loaded from `shell/fish/config.fish`.

**Loading order:**
1. All `path.fish` files (sets up PATH)
2. All `env.fish` files (environment variables)
3. All other `*.fish` files (aliases, functions)
4. All `init.fish` files (initialization scripts)

**Key files:**
- `shell/fish/config.fish` - Main configuration
- `shell/fish/install.sh` - Fish setup script

**Usage:**
```bash
# Reload configuration
source ~/.config/fish/config.fish

# Or use the reload function if defined
reload
```

### ZSH Shell (Optional)

ZSH support is available but optional. Configuration is loaded from `shell/zsh/zshrc.symlink`.

**Loading order:**
1. All `path.zsh` files (sets up PATH)
2. All other `*.zsh` files (except completion)
3. Shell completion initialization (`compinit`)
4. All `completion.zsh` files

**Key files:**
- `shell/zsh/zshrc.symlink` → `~/.zshrc`
- `shell/zsh/*.zsh` - ZSH configurations

**Usage:**
```bash
# Reload configuration
source ~/.zshrc
```

## Topic-Centric Organization

Each tool/topic follows this pattern:

### File Naming Conventions

| Pattern | Purpose | Example |
|---------|---------|---------|
| `*.fish` | Fish shell config | `git/aliases.fish` |
| `*.zsh` | ZSH shell config | `git/aliases.zsh` |
| `path.fish` | PATH setup (Fish) | `homebrew/path.fish` |
| `path.zsh` | PATH setup (ZSH) | `homebrew/path.zsh` |
| `env.fish` | Environment vars (Fish) | `editors/env.fish` |
| `env.zsh` | Environment vars (ZSH) | `system/env.zsh` |
| `completion.zsh` | ZSH completions | `git/completion.zsh` |
| `init.fish` | Fish initialization | `atuin/init.fish` |
| `*.symlink` | Symlinked to $HOME | `git/gitconfig.symlink` |
| `install.sh` | Installation script | `fish/install.sh` |

### Example Topic: Git

```
tools/git/
├── gitconfig.symlink           → ~/.gitconfig
├── gitconfig.local.symlink     → ~/.gitconfig.local (private)
├── gitignore.symlink           → ~/.gitignore
├── aliases.fish                # Fish aliases
├── aliases.zsh                 # ZSH aliases
└── completion.zsh              # ZSH completions
```

## Tool Configurations

### Atuin (Shell History)

```bash
# Located in: config/tools/atuin/
# Purpose: Sync shell history across machines
# Files: env.zsh, init.fish
```

### Docker

```bash
# Located in: config/tools/docker/
# Purpose: Docker command aliases
# Files: aliases.fish, aliases.zsh
```

### Editors

```bash
# Located in: config/tools/editors/
# Purpose: Editor environment variables (EDITOR, VISUAL)
# Files: env.fish, env.zsh
```

### Git

```bash
# Located in: config/tools/git/
# Purpose: Git configuration and aliases
# Files: gitconfig.symlink, aliases.fish, aliases.zsh, completion.zsh
```

### Homebrew

```bash
# Located in: config/tools/homebrew/
# Purpose: Homebrew PATH setup
# Files: path.fish, path.zsh, install.sh
```

### Vim

```bash
# Located in: config/tools/vim/
# Purpose: Vim configuration
# Files: vimrc.symlink → ~/.vimrc
```

### Xcode

```bash
# Located in: config/tools/xcode/
# Purpose: Xcode and iOS development aliases
# Files: aliases.fish, aliases.zsh
```

## Utility Scripts (bin/)

The `bin/` directory contains utility scripts automatically added to your PATH.

**Common utilities:**
- `dot` - Update dotfiles, packages, and configurations
- `e` - Open file in $EDITOR
- `search` - Search for text in files
- `headers` - Show HTTP headers
- `battery-status` - Show battery information

**Git utilities:**
- `git-all` - Run git command in all subdirectories
- `git-rank-contributors` - Show contributor statistics
- `git-delete-local-merged` - Clean up merged branches
- `git-undo` - Undo last commit
- And many more...

## Adding New Configurations

### Adding a New Tool

1. Create directory: `mkdir config/tools/newtool`
2. Add configuration files:
   - `aliases.fish` - Fish aliases
   - `aliases.zsh` - ZSH aliases
   - `env.fish` - Environment variables
   - `install.sh` - Installation script (if needed)
3. Files are auto-loaded by shell configs

### Adding Aliases

**Fish:**
```fish
# config/tools/newtool/aliases.fish
alias nt='newtool --some-flag'
```

**ZSH:**
```bash
# config/tools/newtool/aliases.zsh
alias nt='newtool --some-flag'
```

### Adding to PATH

**Fish:**
```fish
# config/tools/newtool/path.fish
fish_add_path /usr/local/newtool/bin
```

**ZSH:**
```bash
# config/tools/newtool/path.zsh
export PATH="$HOME/.newtool/bin:$PATH"
```

### Adding Symlinks

1. Create file: `config/tools/newtool/config.symlink`
2. Run bootstrap: `./machine-setup/bootstrap.sh`
3. Symlink created: `~/.config` → `~/.dotfiles/config/tools/newtool/config.symlink`

## Private/Local Configuration

### Local Shell Config

For private/sensitive data, use local config files:

**Fish:**
```fish
# ~/.localrc.fish (gitignored)
set -x SECRET_API_KEY "your-key-here"
```

**ZSH:**
```bash
# ~/.localrc (gitignored)
export SECRET_API_KEY="your-key-here"
```

These are automatically sourced if they exist.

### Local Git Config

```bash
# ~/.gitconfig.local (created by bootstrap, gitignored)
[user]
  name = Your Name
  email = your@email.com
```

## Shell-Specific Notes

### Fish Shell

- **Configuration file**: `~/.config/fish/config.fish` (symlinked)
- **Function directory**: `~/.config/fish/functions/`
- **Auto-loading**: All `.fish` files in topic directories
- **Completions**: Built-in, no extra setup needed

### ZSH Shell

- **Configuration file**: `~/.zshrc` (symlinked)
- **Completions**: Need `compinit` initialization
- **Auto-loading**: All `.zsh` files in topic directories
- **Prompt**: Configured in `shell/zsh/prompt.zsh`

## Troubleshooting

### Aliases Not Working

```bash
# Fish
source ~/.config/fish/config.fish

# ZSH
source ~/.zshrc

# Check if file is being loaded
grep -r "alias name" config/
```

### PATH Not Updated

```bash
# Fish
echo $PATH | tr ' ' '\n'

# ZSH
echo $PATH | tr ':' '\n'

# Re-run bootstrap
./machine-setup/bootstrap.sh
```

### Symlinks Broken

```bash
# Check symlinks
ls -la ~/ | grep "dotfiles"

# Re-create symlinks
./machine-setup/bootstrap.sh
```

## Next Steps

- **Customize shell** - Edit files in `config/shell/`
- **Add tools** - Create new directories in `config/tools/`
- **Set up AI** - See `ai/README.md`
- **Add utilities** - Create scripts in `config/bin/`
