if status is-interactive
    # Commands to run in interactive sessions can go here
    atuin init fish | source
end

# Starship Theme
# https://starship.rs/guide/#fish
starship init fish | source

# Path additions
# fish_add_path $HOME/.local/bin

# Variables
set -x MANAGARR_CONFIG_FILE $HOME/.config/managarr/config.yml

# Alias definitions
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# UV Auto-Completion
uv generate-shell-completion fish | source
uvx --generate-shell-completion fish | source

# Zoxide
zoxide init fish | source
