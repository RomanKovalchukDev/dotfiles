#!/usr/bin/env fish
#
# Configure Tide prompt theme with preferred settings
# Run this after Tide is installed via Fisher
#

echo "Configuring Tide prompt theme..."

# Prompt Layout
set -U tide_left_prompt_items pwd git character
set -U tide_right_prompt_items status cmd_duration jobs node python java ruby go kubectl

# Remove hostname from prompt
set -U tide_context_always_display false

# Prompt Appearance
set -U tide_character_color brgreen
set -U tide_character_color_failure brred
set -U tide_character_icon '>'

# Git colors
set -U tide_git_color_branch brgreen
set -U tide_git_color_dirty bryellow  
set -U tide_git_color_staged bryellow
set -U tide_git_color_untracked brblue

# Directory colors
set -U tide_pwd_color_anchors brcyan
set -U tide_pwd_color_dirs cyan

echo "Tide configuration complete!"
