#!/bin/bash

set -euo pipefail

if command -v bat >/dev/null 2>&1; then
    bat_bin="$(command -v bat)"
elif command -v batcat >/dev/null 2>&1; then
    bat_bin="$(command -v batcat)"
elif [[ -x /opt/homebrew/bin/bat ]]; then
    bat_bin=/opt/homebrew/bin/bat
elif [[ -x /usr/local/bin/bat ]]; then
    bat_bin=/usr/local/bin/bat
else
    echo "[INFO] bat not installed; skipping theme cache rebuild."
    exit 0
fi

config_dir="$("${bat_bin}" --config-dir)"
cache_dir="$("${bat_bin}" --cache-dir)"
bat_version="$("${bat_bin}" --version)"
stamp_file="${cache_dir}/.chezmoi-themes.sha256"

# GNU coreutils is available on Ubuntu; macOS provides shasum.
if command -v sha256sum >/dev/null 2>&1; then
    hash_command=(sha256sum)
else
    hash_command=(shasum -a 256)
fi

# Check downloaded files at runtime, after externals have been applied.
theme_hashes=""
if [[ -d "${config_dir}/themes" ]]; then
    theme_hashes="$(find "${config_dir}/themes" -type f -name '*.tmTheme' -exec "${hash_command[@]}" {} + | LC_ALL=C sort)"
fi
fingerprint="$(printf '%s\n' "${bat_version}" "${config_dir}" "${theme_hashes}" | "${hash_command[@]}")"

if [[ -f "${cache_dir}/themes.bin" &&
      -f "${cache_dir}/syntaxes.bin" &&
      -f "${cache_dir}/metadata.yaml" &&
      -f "${stamp_file}" &&
      "$(< "${stamp_file}")" == "${fingerprint}" ]]; then
    exit 0
fi

"${bat_bin}" cache --build
# Record the fingerprint only after a successful rebuild so failures are retried.
printf '%s\n' "${fingerprint}" > "${stamp_file}"
