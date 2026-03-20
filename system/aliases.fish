# System aliases

# Reload fish configuration
alias reload='source ~/.config/fish/config.fish'

# Clear screen
alias cls='clear'

# Public key to clipboard
alias pubkey="cat ~/.ssh/id_rsa.pub | pbcopy; and echo '=> Public key copied to pasteboard.'"

# Enhanced ls with color (using coreutils gls if available)
if command -v gls >/dev/null
    alias ls='gls -F --color'
    alias l='gls -lAh --color'
    alias ll='gls -l --color'
    alias la='gls -A --color'
end
