if status is-interactive
    # Commands to run in interactive sessions can go here
    fastfetch
end

set -gx PATH ~/.npm-global/bin $PATH

set -gx DOCKER_HOST "unix://$XDG_RUNTIME_DIR/docker.sock"

direnv hook fish | source
