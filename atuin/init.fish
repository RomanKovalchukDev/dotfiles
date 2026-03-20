# Atuin shell history
# Loaded last (zz- prefix) to ensure it runs after other setup

if command -v atuin >/dev/null
    atuin init fish | source
end
