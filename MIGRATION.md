# Migration Guide

Documentation of the dotfiles restructure from flat topic-centric structure to organized machine-setup/config/ai layout.

## Overview

This migration reorganizes the dotfiles repository into three main directories:

- **machine-setup/** - Machine provisioning and installation
- **config/** - Shell and tool configurations
- **ai/** - AI tool configurations (Claude Code, etc.)

## Current → New Structure Mapping

### Root Files

| Current | New Location | Notes |
|---------|-------------|-------|
| `Brewfile` | `machine-setup/Brewfile` | Homebrew packages |
| `README.md` | `README.md` | Updated to reflect new structure |
| `LICENSE.md` | `LICENSE.md` | No change |
| `CLAUDE.md` | `ai/CLAUDE.md` | Moved to AI section |

### Directories

| Current | New Location | Purpose |
|---------|-------------|---------|
| `script/` | `machine-setup/mac/bin/` | Installation scripts |
| `macos/` | `machine-setup/mac/` | macOS configuration |
| `.claude/` | `ai/.claude/` | Project-level Claude config |
| `claude/` | `ai/claude/` | User-level Claude config |
| `fish/` | `config/shell/fish/` | Fish shell |
| `zsh/` | `config/shell/zsh/` | ZSH shell |
| `atuin/` | `config/tools/atuin/` | Atuin history sync |
| `docker/` | `config/tools/docker/` | Docker aliases |
| `editors/` | `config/tools/editors/` | Editor config |
| `git/` | `config/tools/git/` | Git configuration |
| `homebrew/` | `config/tools/homebrew/` | Homebrew paths |
| `vim/` | `config/tools/vim/` | Vim configuration |
| `xcode/` | `config/tools/xcode/` | Xcode aliases |
| `system/` | `config/system/` | System settings |
| `bin/` | `config/bin/` | Utility scripts |
| `functions/` | `functions/` | No change (stays at root) |
| `example/` | `example/` | No change (stays at root) |

## Symlink Mappings

### Git Configuration

| File | Symlink Target | New Location |
|------|---------------|--------------|
| `git/gitconfig.symlink` | `~/.gitconfig` | `config/tools/git/gitconfig.symlink` |
| `git/gitconfig.local.symlink` | `~/.gitconfig.local` | `config/tools/git/gitconfig.local.symlink` |
| `git/gitignore.symlink` | `~/.gitignore` | `config/tools/git/gitignore.symlink` |

### Vim Configuration

| File | Symlink Target | New Location |
|------|---------------|--------------|
| `vim/vimrc.symlink` | `~/.vimrc` | `config/tools/vim/vimrc.symlink` |

### Shell Configuration

| File | Symlink Target | New Location |
|------|---------------|--------------|
| `zsh/zshrc.symlink` | `~/.zshrc` | `config/shell/zsh/zshrc.symlink` |
| `fish/config.fish` | `~/.config/fish/config.fish` | `config/shell/fish/config.fish` (via install.sh) |

### Claude Code Configuration

| File | Symlink Target | New Location |
|------|---------------|--------------|
| `claude/settings.json` | `~/.claude/settings.json` | `ai/claude/settings.json` |
| `claude/skills/*` | `~/.claude/skills/*` | `ai/claude/skills/*` (via install.sh) |
| `claude/agents/*` | `~/.claude/agents/*` | `ai/claude/agents/*` (via install.sh) |

## Script Path Updates

### bootstrap.sh

**Old path:** `script/bootstrap`
**New path:** `machine-setup/mac/bootstrap.sh`

**References to update:**
- `~/.dotfiles/script/bootstrap` → `~/.dotfiles/machine-setup/bootstrap.sh`
- All internal paths to find `*.symlink` files
- Git config path references

### install.sh

**Old path:** `script/install`
**New path:** `machine-setup/mac/install.sh`

**References to update:**
- `~/.dotfiles/script/install` → `~/.dotfiles/machine-setup/mac/install.sh`
- Brewfile path: `./Brewfile` → `./machine-setup/mac/bin/Brewfile`
- Search paths for `install.sh` files
- Claude install path: `./claude/install.sh` → `./ai/claude/install.sh`

### claude/install.sh

**Old path:** `claude/install.sh`
**New path:** `ai/claude/install.sh`

**References to update:**
- Skills path: `./claude/skills` → `./ai/claude/skills`
- Agents path: `./claude/agents` → `./ai/claude/agents`
- Settings path: `./claude/settings.json` → `./ai/claude/settings.json`
- Statusline path: `./claude/statusline.sh` → `./ai/claude/statusline.sh`

### dot utility

**Location:** `config/bin/dot` (moved from `bin/dot`)

**References to update:**
- Dotfiles path assumptions
- Script invocation paths
- Brew bundle path

## Shell Configuration Updates

### Fish config.fish

**Old path:** `fish/config.fish`
**New path:** `config/shell/fish/config.fish`

**References to update:**
```fish
# Old: searches current directory for topic files
set DOTFILES_ROOT (pwd -P)

# New: needs to go up one level
set DOTFILES_ROOT (dirname (dirname (status -f)))
# Or use absolute path
set DOTFILES_ROOT ~/.dotfiles
```

**File discovery paths:**
- `*/path.fish` → `config/**/path.fish` (need recursive search)
- `*/env.fish` → `config/**/env.fish`
- `*/*.fish` → `config/**/*.fish`
- `*/init.fish` → `config/**/init.fish`

### ZSH zshrc.symlink

**Old path:** `zsh/zshrc.symlink`
**New path:** `config/shell/zsh/zshrc.symlink`

**References to update:**
```bash
# Old: dotfiles directory assumed to be parent
DOTFILES=$HOME/.dotfiles

# New: same, but internal paths different
# Search for *.zsh files in new structure
typeset -U config_files
config_files=($DOTFILES/config/**/*.zsh)
```

**File discovery paths:**
- `**/path.zsh` → `config/**/path.zsh`
- `**/*.zsh` → `config/**/*.zsh`
- `**/completion.zsh` → `config/**/completion.zsh`

## Hook Updates

### .claude/hooks/session-start.sh

**Old path:** `.claude/hooks/session-start.sh`
**New path:** `ai/.claude/hooks/session-start.sh`

**References to update:**
- Shell detection logic (no change needed)
- Skills count: `~/.claude/skills` (no change)
- Config status reporting

### .claude/hooks/pre-tool-use.sh

**Old path:** `.claude/hooks/pre-tool-use.sh`
**New path:** `ai/.claude/hooks/pre-tool-use.sh`

**References to update:**
- Topic pattern validation
- File path expectations (should work with new structure)

## Migration Steps (When Ready)

### Phase 2: machine-setup/

```bash
# Create backup
git tag -a pre-migration-phase2 -m "Before machine-setup migration"

# Move files
git mv Brewfile machine-setup/Brewfile
git mv script/bootstrap machine-setup/bootstrap.sh
git mv script/install machine-setup/install.sh
git mv macos machine-setup/macos
git mv script machine-setup/scripts

# Update script references (do this in next step)
```

### Phase 3: config/

```bash
# Create backup
git tag -a pre-migration-phase3 -m "Before config migration"

# Move shell configs
git mv fish config/shell/fish
git mv zsh config/shell/zsh

# Move tool configs
git mv atuin config/tools/atuin
git mv docker config/tools/docker
git mv editors config/tools/editors
git mv git config/tools/git
git mv homebrew config/tools/homebrew
git mv vim config/tools/vim
git mv xcode config/tools/xcode

# Move system
git mv system config/system

# Move bin
git mv bin config/bin

# Update config file paths (do this in next step)
```

### Phase 4: ai/

```bash
# Create backup
git tag -a pre-migration-phase4 -m "Before AI migration"

# Move Claude configs
git mv .claude ai/.claude
git mv claude ai/claude
git mv CLAUDE.md ai/CLAUDE.md

# Create new files
# AGENTS.md already created in ai/
# README.md already created in ai/

# Update Claude install script (do this in next step)
```

### Phase 5: Update Scripts

This phase requires editing files to update paths. See "Script Path Updates" section above.

**Files to edit:**
1. `machine-setup/mac/bootstrap.sh` - Update symlink search paths
2. `machine-setup/mac/install.sh` - Update Brewfile path, claude install path
3. `config/shell/fish/config.fish` - Update file discovery paths
4. `config/shell/zsh/zshrc.symlink` - Update file discovery paths
5. `ai/claude/install.sh` - Update skills/agents/settings paths
6. `config/bin/dot` - Update script invocation paths

### Phase 6: Testing

```bash
# Test bootstrap
./machine-setup/mac/bootstrap.sh

# Verify symlinks
ls -la ~/ | grep "dotfiles"
ls -la ~/.config/ | grep "fish"

# Test install
./machine-setup/mac/install.sh

# Test shell configs
fish -c "echo \$PATH"
zsh -c "echo \$PATH"

# Test AI install
./ai/claude/install.sh
ls -la ~/.claude/skills/ | wc -l
```

## Rollback Plan

If anything goes wrong:

```bash
# Rollback to pre-restructure
git checkout pre-restructure-v1

# Or rollback phase by phase
git checkout pre-migration-phase2  # Before machine-setup/
git checkout pre-migration-phase3  # Before config/
git checkout pre-migration-phase4  # Before ai/
```

## Breaking Changes

### For Users

1. **Script paths changed** - Update any external scripts calling `script/bootstrap` or `script/install`
2. **Topic paths changed** - If you reference topic paths directly, update them
3. **Claude paths changed** - Update any references to `claude/` or `.claude/`

### For External Tools

1. **CI/CD pipelines** - Update paths in CI configs
2. **Ansible/Chef/Puppet** - Update automation scripts
3. **Documentation** - Update any docs referencing old paths

## Verification Checklist

After migration, verify:

- [ ] `machine-setup/mac/bootstrap.sh` runs successfully
- [ ] `machine-setup/mac/install.sh` runs successfully
- [ ] All `*.symlink` files create symlinks in `$HOME`
- [ ] Fish shell loads configuration correctly
- [ ] ZSH shell loads configuration correctly
- [ ] Git config works (`git config user.name`)
- [ ] Vim config loads (`vim` shows custom settings)
- [ ] `bin/` utilities are in PATH (`which dot`)
- [ ] `ai/claude/install.sh` runs successfully
- [ ] 49 skills symlinked to `~/.claude/skills/`
- [ ] 2 agents symlinked to `~/.claude/agents/`
- [ ] Claude Code settings loaded
- [ ] Hooks execute on Claude Code session start

## Timeline

**Phase 1: Preparation** (Current)
- ✅ Create directory structure
- ✅ Write README files
- ✅ Document migrations
- ✅ Create backup tag

**Phase 2-4: Migration** (Next)
- Move files to new locations
- Update internal references

**Phase 5: Testing** (After)
- Test in clean environment
- Fix any broken paths
- Verify all functionality

**Phase 6: Deployment** (Final)
- Merge to main
- Tag as v2.0.0
- Update documentation

## Support

If you encounter issues:

1. Check this migration guide
2. Review "Script Path Updates" section
3. Test in a clean VM/container first
4. Create an issue if stuck

## Resources

- **Old structure**: `git show pre-restructure-v1:README.md`
- **New structure**: `README.md` (this branch)
- **Diff**: `git diff pre-restructure-v1...restructure-dotfiles`
