#!/bin/bash

set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"
mkdir -p "${HOME}/.local/share" "${HOME}/.config/chezmoi"
cp -R /opt/dotfiles "${HOME}/.local/share/chezmoi"
cd "${HOME}/.local/share/chezmoi"

# Seed a disposable identity so the real installer can run without prompts.
cat > "${HOME}/.config/chezmoi/chezmoi.toml" <<'CONFIG'
[data]
name = "Ubuntu container test"
email = "ubuntu-test@example.invalid"
CONFIG

if ! sh ./install.sh </dev/null; then
    echo "[ERROR] Installation failed. Opening Bash so you can inspect and retry sh ./install.sh." >&2
    echo "Exit the shell to remove the container."
    exec bash --noprofile --norc -i
fi

printf '\nDotfiles installed as %s. Opening Fish for manual testing.\n' "$(id -un)"
echo "Try: tmux, chezmoi diff, or chezmoi apply --refresh-externals --force"
echo "Source checkout: ${PWD}"
echo "Exit the shell to remove the container; changes here do not affect the host checkout."
exec fish --login --interactive
