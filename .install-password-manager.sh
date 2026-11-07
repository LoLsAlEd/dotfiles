#!/bin/bash

set -euo pipefail

# This hook also runs for previews. Avoid installing or authenticating when op
# is already available, including when Homebrew is absent from the caller's PATH.
[[ "$(uname -s)" == Darwin ]] || exit 0

find_op() {
    if command -v op >/dev/null 2>&1; then
        command -v op
    elif [[ -x /opt/homebrew/bin/op ]]; then
        printf '%s\n' /opt/homebrew/bin/op
    elif [[ -x /usr/local/bin/op ]]; then
        printf '%s\n' /usr/local/bin/op
    else
        return 1
    fi
}

find_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        command -v brew
    elif [[ -x /opt/homebrew/bin/brew ]]; then
        printf '%s\n' /opt/homebrew/bin/brew
    elif [[ -x /usr/local/bin/brew ]]; then
        printf '%s\n' /usr/local/bin/brew
    else
        return 1
    fi
}

if find_op >/dev/null; then
    exit 0
fi

if ! brew_bin="$(find_homebrew)"; then
    source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    # Reuse the same bootstrap as apply, without reading chezmoi's source state
    # recursively. This file is plain shell, not a chezmoi template.
    /bin/bash "${source_dir}/.chezmoiscripts/run_once_01_install_homebrew.sh" >&2
    if ! brew_bin="$(find_homebrew)"; then
        echo "[ERROR] Homebrew bootstrap did not provide brew for the 1Password CLI installation." >&2
        exit 1
    fi
fi

if [[ -x "${brew_bin%/*}/op" ]]; then
    exit 0
fi

"${brew_bin}" install --cask 1password-cli >&2

if ! find_op >/dev/null && [[ ! -x "${brew_bin%/*}/op" ]]; then
    echo "[ERROR] 1Password CLI installation completed but op was not found." >&2
    exit 1
fi
