function eza --wraps=eza --description 'List files with the configured eza theme'
    # set -lx EZA_CONFIG_DIR "$HOME/.config/eza"
    # Let theme.yml style eza while keeping vivid's LS_COLORS for other tools.
    # set -lx LS_COLORS ''
    command eza $argv
end
