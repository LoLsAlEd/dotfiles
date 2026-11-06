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
            for target_os in darwin linux; do
                echo "Checking ${source_file} (${target_os})"
                rendered_file="${temporary_dir}/rendered-script"
                chezmoi --config /dev/null --config-format toml \
                    --source "${repo_root}" \
                    --override-data "{\"name\":\"Hook validation\",\"email\":\"hooks@example.invalid\",\"chezmoi\":{\"os\":\"${target_os}\"}}" \
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
