#!/usr/bin/env bash
#
# migrate.sh - Automated migration script for dotfiles restructure
#
# Usage:
#   ./migrate.sh --dry-run    # Preview changes
#   ./migrate.sh --phase2     # Run phase 2 (machine-setup)
#   ./migrate.sh --phase3     # Run phase 3 (config)
#   ./migrate.sh --phase4     # Run phase 4 (ai)
#   ./migrate.sh --all        # Run all phases
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Options
DRY_RUN=false
PHASE2=false
PHASE3=false
PHASE4=false
ALL_PHASES=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --phase2)
      PHASE2=true
      shift
      ;;
    --phase3)
      PHASE3=true
      shift
      ;;
    --phase4)
      PHASE4=true
      shift
      ;;
    --all)
      ALL_PHASES=true
      PHASE2=true
      PHASE3=true
      PHASE4=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: ./migrate.sh [--dry-run] [--phase2|--phase3|--phase4|--all]"
      exit 1
      ;;
  esac
done

# Helper functions
info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

git_move() {
  local src=$1
  local dest=$2

  if [ ! -e "$src" ]; then
    warning "Source does not exist: $src"
    return 1
  fi

  if $DRY_RUN; then
    info "Would move: $src → $dest"
  else
    info "Moving: $src → $dest"
    git mv "$src" "$dest"
  fi
}

create_backup_tag() {
  local tag=$1
  local message=$2

  if $DRY_RUN; then
    info "Would create tag: $tag"
  else
    info "Creating backup tag: $tag"
    git tag -a "$tag" -m "$message"
    success "Backup tag created: $tag"
  fi
}

# Phase 2: machine-setup/
run_phase2() {
  info "=== Phase 2: Migrating to machine-setup/ ==="

  create_backup_tag "pre-migration-phase2" "Before machine-setup migration"

  # Move bootstrap script
  if [ -f "script/bootstrap" ]; then
    git_move "script/bootstrap" "machine-setup/mac/bootstrap.sh"
  fi

  # Move install script
  if [ -f "script/install" ]; then
    git_move "script/install" "machine-setup/mac/install.sh"
  fi

  # Move Brewfile to mac/bin
  git_move "Brewfile" "machine-setup/mac/bin/Brewfile"

  # Move macos directory contents to mac/
  if [ -d "macos" ]; then
    git_move "macos/set-defaults.sh" "machine-setup/mac/set-defaults.sh" 2>/dev/null || true
    git_move "macos/set-hostname.sh" "machine-setup/mac/set-hostname.sh" 2>/dev/null || true
    # Remove old directory if empty
    if [ -z "$(ls -A macos 2>/dev/null)" ]; then
      rmdir macos 2>/dev/null || true
    fi
  fi

  # Move remaining script directory contents to mac/bin/
  if [ -d "script" ]; then
    for file in script/*; do
      if [ -e "$file" ]; then
        filename=$(basename "$file")
        git_move "$file" "machine-setup/mac/bin/$filename"
      fi
    done
    # Remove old directory if empty
    if [ -z "$(ls -A script 2>/dev/null)" ]; then
      rmdir script 2>/dev/null || true
    fi
  fi

  success "Phase 2 complete"
}

# Phase 3: config/
run_phase3() {
  info "=== Phase 3: Migrating to config/ ==="

  create_backup_tag "pre-migration-phase3" "Before config migration"

  # Move shell configs
  [ -d "fish" ] && git_move "fish" "config/shell/fish"
  [ -d "zsh" ] && git_move "zsh" "config/shell/zsh"

  # Move tool configs
  [ -d "atuin" ] && git_move "atuin" "config/tools/atuin"
  [ -d "docker" ] && git_move "docker" "config/tools/docker"
  [ -d "editors" ] && git_move "editors" "config/tools/editors"
  [ -d "git" ] && git_move "git" "config/tools/git"
  [ -d "homebrew" ] && git_move "homebrew" "config/tools/homebrew"
  [ -d "vim" ] && git_move "vim" "config/tools/vim"
  [ -d "xcode" ] && git_move "xcode" "config/tools/xcode"

  # Move system
  [ -d "system" ] && git_move "system" "config/system"

  # Move bin
  [ -d "bin" ] && git_move "bin" "config/bin"

  success "Phase 3 complete"
}

# Phase 4: ai/
run_phase4() {
  info "=== Phase 4: Migrating to ai/ ==="

  create_backup_tag "pre-migration-phase4" "Before AI migration"

  # Move Claude configs
  [ -d ".claude" ] && git_move ".claude" "ai/.claude"
  [ -d "claude" ] && git_move "claude" "ai/claude"
  [ -f "CLAUDE.md" ] && git_move "CLAUDE.md" "ai/CLAUDE.md"

  success "Phase 4 complete"
}

# Main execution
main() {
  # Check if we're in a git repo
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    error "Not in a git repository"
    exit 1
  fi

  # Check for uncommitted changes
  if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    warning "You have uncommitted changes. Consider committing or stashing them first."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi

  if $DRY_RUN; then
    warning "=== DRY RUN MODE - No changes will be made ==="
  fi

  # Run phases
  if $PHASE2 || $ALL_PHASES; then
    run_phase2
  fi

  if $PHASE3 || $ALL_PHASES; then
    run_phase3
  fi

  if $PHASE4 || $ALL_PHASES; then
    run_phase4
  fi

  # If no phase specified, show help
  if ! $PHASE2 && ! $PHASE3 && ! $PHASE4; then
    info "No phase specified. Use one of:"
    echo "  ./migrate.sh --dry-run --all   # Preview all changes"
    echo "  ./migrate.sh --phase2          # Run phase 2 (machine-setup)"
    echo "  ./migrate.sh --phase3          # Run phase 3 (config)"
    echo "  ./migrate.sh --phase4          # Run phase 4 (ai)"
    echo "  ./migrate.sh --all             # Run all phases"
    exit 0
  fi

  if $DRY_RUN; then
    info "Dry run complete. Run without --dry-run to apply changes."
  else
    success "Migration complete!"
    info "Next steps:"
    echo "  1. Review changes: git status"
    echo "  2. Update script references (see MIGRATION.md)"
    echo "  3. Test: ./machine-setup/bootstrap.sh"
    echo "  4. Commit: git commit -m 'Restructure dotfiles'"
  fi
}

main
