#!/bin/bash

set -euo pipefail

detect_linux_distribution() {
    if [[ -r /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        printf '%s\n' "${ID:-unknown}"
    elif command -v lsb_release >/dev/null 2>&1; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    else
        printf '%s\n' "unknown"
    fi
}

run_as_root() {
    if [[ ${EUID} -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo "[ERROR] Unable to escalate privileges to run '$*'." >&2
        exit 1
    fi
}

ensure_curl() {
    if command -v curl >/dev/null 2>&1; then
        return
    fi

    echo -e "[INFO] curl not found. Attempting to install..."

    if command -v apt-get >/dev/null 2>&1; then
        run_as_root apt-get update -y
        run_as_root apt-get install -y curl
    elif command -v dnf >/dev/null 2>&1; then
        run_as_root dnf install -y curl
    elif command -v yum >/dev/null 2>&1; then
        run_as_root yum install -y curl
    elif command -v pacman >/dev/null 2>&1; then
        run_as_root pacman -Sy --noconfirm curl
    elif command -v zypper >/dev/null 2>&1; then
        run_as_root zypper --non-interactive install curl
    else
        echo "[ERROR] curl is required but no supported package manager was detected." >&2
        exit 1
    fi
}

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

install_homebrew_linux() {
    if command -v brew >/dev/null 2>&1; then
        echo -e "[INFO] Homebrew already installed on Linux"
        return
    fi

    echo -e "[INFO] Installing Homebrew on Linux..."
    ensure_curl
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    append_shellenv_statement
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

OS="$(uname -s)"
case "${OS}" in
    Linux*)
        linux_id="$(detect_linux_distribution)"
        case "${linux_id}" in
            debian|ubuntu|linuxmint|elementary|pop|zorin|fedora|rhel|centos|rocky|almalinux|amzn|amazon|sles|opensuse*|arch|manjaro|endeavouros|unknown)
                install_homebrew_linux
                ;;
            *)
                echo -e "[WARN] Detected Linux distribution '${linux_id}' is untested; attempting Homebrew install anyway."
                install_homebrew_linux
                ;;
        esac
        ;;
    Darwin*)
        install_homebrew_mac
        ;;
    *)
        echo "[ERROR] Unsupported operating system: ${OS}"
        exit 1
        ;;
esac

echo "[SUCCESS] Homebrew installation complete."
