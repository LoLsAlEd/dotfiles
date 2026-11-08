#!/bin/bash

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
temporary_dir="$(mktemp -d)"
trap 'rm -rf "${temporary_dir}"' EXIT

check_script() {
    local source_file="$1" script_file="$2"

    case "${source_file}" in
        *.fish|*.fish.tmpl)
            fish --no-execute "${script_file}"
            ;;
        *)
            shellcheck "${script_file}"
            ;;
    esac
}

for source_file in "$@"; do
    case "${source_file}" in
        *.tmpl)
            for target in darwin:arm64 darwin:amd64 linux:arm64; do
                target_os="${target%:*}"
                target_arch="${target#*:}"
                echo "Checking ${source_file} (${target})"
                rendered_file="${temporary_dir}/rendered-script"
                chezmoi --config /dev/null --config-format toml \
                    --source "${repo_root}" \
                    --override-data "{\"name\":\"Hook validation\",\"email\":\"hooks@example.invalid\",\"chezmoi\":{\"os\":\"${target_os}\",\"arch\":\"${target_arch}\",\"osRelease\":{\"id\":\"ubuntu\",\"versionID\":\"26.04\"}}}" \
                    execute-template --file "${repo_root}/${source_file}" > "${rendered_file}"
                if [[ -s "${rendered_file}" ]]; then
                    check_script "${source_file}" "${rendered_file}"
                fi
            done
            ;;
        *)
            echo "Checking ${source_file}"
            check_script "${source_file}" "${repo_root}/${source_file}"
            ;;
    esac
done
