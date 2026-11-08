#!/bin/bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
image="chezmoi-ubuntu-test:26.04"

if ! docker info >/dev/null 2>&1; then
    echo "[ERROR] Start your Docker runtime before running the Ubuntu tests." >&2
    exit 1
fi

docker build --file "${repo_root}/tests/ubuntu/Dockerfile" --tag "${image}" "${repo_root}"
for test_user in root dotfiles; do
    echo "[TEST] Ubuntu 26.04 bootstrap as ${test_user}"
    if [[ "${test_user}" == root ]]; then
        test_home=/root
    else
        test_home=/home/dotfiles
    fi
    docker run --rm --user "${test_user}" --env "HOME=${test_home}" "${image}"
done
