#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: bash tests/manual-ubuntu.sh [dotfiles|root]"
    echo "Install the current checkout in a disposable Ubuntu 26.04 container and open Fish."
}

if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then
    usage
    exit 0
fi
test_user="${1:-dotfiles}"
if [[ $# -gt 1 || ( "${test_user}" != dotfiles && "${test_user}" != root ) ]]; then
    usage >&2
    exit 1
fi

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
image="chezmoi-ubuntu-test:26.04"
if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
    echo "[ERROR] Install Docker and start your Docker runtime before launching the container." >&2
    exit 1
fi

docker build --file "${repo_root}/tests/ubuntu/Dockerfile" --tag "${image}" "${repo_root}"
if [[ "${test_user}" == root ]]; then
    test_home=/root
else
    test_home=/home/dotfiles
fi
exec docker run --rm -it --user "${test_user}" --env "HOME=${test_home}" \
    --entrypoint bash "${image}" tests/ubuntu/manual-bootstrap.sh
