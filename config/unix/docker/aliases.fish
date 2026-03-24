#!/usr/bin/env fish
# Docker aliases for Fish

# Docker shortcuts
function d
    docker $argv
end

function d-c
    docker-compose $argv
end
