#!/bin/bash

set -euo pipefail
trap 'echo "[FAIL] Line ${LINENO}: ${BASH_COMMAND}" >&2' ERR

export PATH="${HOME}/.local/bin:${PATH}"
temporary_dir="$(mktemp -d)"
trap 'tmux -L chezmoi-test kill-server 2>/dev/null || true; rm -rf "${temporary_dir}"' EXIT

# Use chezmoi's normal source location so subsequent commands exercise the
# generated configuration without supplying a source override.
mkdir -p "${HOME}/.local/share"
cp -R /opt/dotfiles "${HOME}/.local/share/chezmoi"
cd "${HOME}/.local/share/chezmoi"

# Exercise the real installer, including chezmoi installation and init, without
# prompting for an identity or using personal credentials.
mkdir -p "${HOME}/.config/chezmoi"
cat > "${HOME}/.config/chezmoi/chezmoi.toml" <<'CONFIG'
[data]
name = "Ubuntu container test"
email = "ubuntu-test@example.invalid"
CONFIG
original_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
sh ./install.sh </dev/null

for tool in chezmoi fish starship atuin git delta tmux fzf bat eza fd rg zoxide jq micro curl ssh less unzip ps; do
    command -v "${tool}" >/dev/null
done
for tool in chezmoi fish starship atuin git delta fzf bat eza fd rg zoxide jq; do
    "${tool}" --version >/dev/null
done
tmux -V >/dev/null
micro -version >/dev/null
test "$(getent passwd "$(id -un)" | cut -d: -f7)" = "${original_shell}"
if command -v brew; then exit 1; fi
test ! -e "${HOME}/.ssh/config.d/1password"
test ! -e "${HOME}/.config/ghostty"
if grep -RE '/Users/|Library/Group Containers|UseKeychain|lima-ubuntu' "${HOME}/.ssh"; then exit 1; fi
ssh -G -T github > "${temporary_dir}/ssh-config"
grep -q '^hostname github.com$' "${temporary_dir}/ssh-config"
if grep -q '^identityagent ' "${temporary_dir}/ssh-config"; then exit 1; fi
test "$(git config --global core.pager)" = delta
if git config --global --get commit.gpgsign; then exit 1; fi

fish --no-execute "${HOME}/.config/fish/config.fish"
env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    fish --interactive tests/ubuntu/check-fish.fish > "${temporary_dir}/fish-output" 2> "${temporary_dir}/fish-errors"
cat "${temporary_dir}/fish-output"
if [[ -s "${temporary_dir}/fish-errors" ]]; then
    cat "${temporary_dir}/fish-errors" >&2
    exit 1
fi
bat --list-themes --color=never | grep -q '^Catppuccin Mocha$'
bat --paging=never README.md >/dev/null
tmux -L chezmoi-test new-session -d -s bootstrap
test "$(tmux -L chezmoi-test show-option -gv default-shell)" = /usr/bin/fish
tmux -L chezmoi-test kill-server

# Check actual managed files and cache timestamps, rather than only exit codes.
managed_fingerprints() {
    chezmoi managed --include=files --path-style=absolute | while IFS= read -r managed_file; do
        sha256sum "${managed_file}"
    done
}
cache_fingerprints() {
    find "$(bat --cache-dir)" -maxdepth 1 -type f -exec stat --format='%n %y %s' {} + | LC_ALL=C sort
}
managed_fingerprints > "${temporary_dir}/managed-before"
cache_fingerprints > "${temporary_dir}/cache-before"
if ! chezmoi apply --refresh-externals --force --verbose > "${temporary_dir}/second-apply" 2>&1; then
    cat "${temporary_dir}/second-apply" >&2
    exit 1
fi
cat "${temporary_dir}/second-apply"
managed_fingerprints > "${temporary_dir}/managed-after"
cache_fingerprints > "${temporary_dir}/cache-after"
diff -u "${temporary_dir}/managed-before" "${temporary_dir}/managed-after"
diff -u "${temporary_dir}/cache-before" "${temporary_dir}/cache-after"
if grep -E 'apt-get|fisher update|02_install_packages|04_install_fish_plugins|rebuilding|Building' "${temporary_dir}/second-apply"; then
    echo "[ERROR] An unchanged apply repeated setup or cache rebuilding." >&2
    exit 1
fi
chezmoi diff --exclude=scripts > "${temporary_dir}/remaining-diff"
test ! -s "${temporary_dir}/remaining-diff"

echo "[PASS] Ubuntu bootstrap and repeat apply as $(id -un)"
