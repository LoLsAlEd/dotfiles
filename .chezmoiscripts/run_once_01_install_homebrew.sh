#!/bin/bash

set -euo pipefail

# Ubuntu uses APT; keep this filename for the macOS 1Password bootstrap hook.
[[ "$(uname -s)" == Darwin ]] || exit 0

append_shellenv_statement() {
    local brew_prefix
    brew_prefix="$(brew --prefix 2>/dev/null)" || return

    local default_file shell_name

    shell_name="$(basename "${SHELL:-}")"
    case "${shell_name}" in
        bash)
            if [[ "$(uname -s)" == Darwin* ]]; then
                # Login Bash reads only the first existing profile.
                for default_file in "${HOME}/.bash_profile" "${HOME}/.bash_login" "${HOME}/.profile"; do
                    [[ -f "${default_file}" ]] && break
                done
                [[ -f "${default_file}" ]] || default_file="${HOME}/.bash_profile"
            else
                default_file="${HOME}/.bashrc"
            fi
            ;;
        zsh)
            default_file="${ZDOTDIR:-${HOME}}/.zprofile"
            ;;
        fish)
            # The managed macOS Fish config initializes Homebrew before hooks.
            [[ "$(uname -s)" == Darwin* ]] && return
            default_file="${XDG_CONFIG_HOME:-${HOME}/.config}/fish/config.fish"
            ;;
        *)
            default_file="${HOME}/.profile"
            shell_name="sh"
            ;;
    esac

    mkdir -p "$(dirname "${default_file}")"

    local eval_statement="eval \"\$(${brew_prefix}/bin/brew shellenv ${shell_name})\""

    if [[ "${shell_name}" == "fish" ]]; then
        local fish_statement
        fish_statement="${brew_prefix}/bin/brew shellenv fish | source"
        if ! grep -Fq "brew shellenv" "${default_file}" 2>/dev/null; then
            printf '\n%s\n' "${fish_statement}" >> "${default_file}"
        fi
    else
        if ! grep -Fq "brew shellenv" "${default_file}" 2>/dev/null; then
            printf '\n%s\n' "${eval_statement}" >> "${default_file}"
        fi
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

install_homebrew_mac() {
    local brew_bin homebrew_shellenv install_script

    if brew_bin="$(find_homebrew)"; then
        echo -e "[INFO] Homebrew already installed on Mac"
    else
        echo -e "[INFO] Installing Homebrew on Mac..."
        install_script="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        /bin/bash -c "${install_script}"

        if ! brew_bin="$(find_homebrew)"; then
            echo "[ERROR] Homebrew not found after installation." >&2
            exit 1
        fi
    fi

    homebrew_shellenv="$("${brew_bin}" shellenv bash)"
    eval "${homebrew_shellenv}"
    append_shellenv_statement
}

install_homebrew_mac

echo "[SUCCESS] Homebrew installation complete."
