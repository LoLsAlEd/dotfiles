if status is-interactive
    # Commands to run in interactive sessions can go here
    atuin init fish | source
    # Starship
    starship init fish | source
end

# Path additions
# fish_add_path $HOME/.local/bin

# Variables
set -x MANAGARR_CONFIG_FILE $HOME/.config/managarr/config.yml
export MANPAGER="bat --plain --language=man"

# Alias definitions
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# UV Auto-Completion
uv generate-shell-completion fish | source
uvx --generate-shell-completion fish | source

zoxide init fish | source
