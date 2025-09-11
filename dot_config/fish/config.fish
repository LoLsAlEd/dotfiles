if status is-interactive
    # Commands to run in interactive sessions can go here

    # Set up fzf key bindings
    if command -q fzf
        fzf --fish | source
    end

    # Starship
    if command -q starship
        starship init fish | source
    end

    # Man page viewer
    if command -q bat
        export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"
    end

    # Shell completions for CLI tools
    if command -q atuin
        atuin init fish | source
    end
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

# Alias definitions
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

if command -q vivid
    set -x LS_COLORS "$(vivid generate catppuccin-mocha)"
end

if command -q vivid
    direnv hook fish | source
end
