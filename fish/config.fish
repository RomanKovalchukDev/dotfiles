# Main fish configuration
# This file will be symlinked to ~/.config/fish/config.fish

# Set dotfiles path
set -gx DOTFILES $HOME/.dotfiles

# Set project folder
set -gx PROJECTS ~/Documents

# Source local config if it exists (for sensitive/local-only variables)
if test -f ~/.localrc.fish
    source ~/.localrc.fish
end

# Load all fish configuration files from topic directories
# This mirrors the zsh loading pattern

# Get all fish config files
set -l config_files $DOTFILES/*/*.fish

# Load the path files first
for file in $config_files
    if string match -q '*/path.fish' $file
        source $file
    end
end

# Load the env files second
for file in $config_files
    if string match -q '*/env.fish' $file
        source $file
    end
end

# Load everything but the path, env, and init files
for file in $config_files
    if not string match -q '*/path.fish' $file
        and not string match -q '*/env.fish' $file
        and not string match -q '*/init.fish' $file
        source $file
    end
end

# Load init files last (for things like atuin that need to initialize after everything else)
for file in $config_files
    if string match -q '*/init.fish' $file
        source $file
    end
end
