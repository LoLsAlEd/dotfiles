if status is-interactive
    # Commands to run in interactive sessions can go here
    atuin init fish | source
    # Starship
    starship init fish | source

    # Shell completions for CLI tools
    if command -q chezmoi
        chezmoi completion fish | source
    end
    if command -q kubectl
        kubectl completion fish | source
    end
    if command -q helm
        helm completion fish | source
    end
    if command -q docker
        docker completion fish | source
    end
    if command -q zoxide
        zoxide init fish | source
    end
    if command -q uv
        uv generate-shell-completion fish | source
    end
    if command -q uvx
        uvx --generate-shell-completion fish | source
    end
end

# Path additions
# fish_add_path $HOME/.local/bin

# Variables
set -x MANAGARR_CONFIG_FILE $HOME/.config/managarr/config.yml
export MANPAGER="bat --plain --language=man"

# Alias definitions
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

set -x LS_COLORS "$(vivid generate catppuccin-mocha)"
