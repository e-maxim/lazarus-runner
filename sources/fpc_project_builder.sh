#!/bin/bash

[[ -n ${FPC_PROJECT_BUILDER_SOURCED:-} ]] && return 0
FPC_PROJECT_BUILDER_SOURCED=1

build_lazarus_projects() {
    local search_dir="$1"
    [[ -z "$search_dir" || ! -d "$search_dir" ]] && exit 0

    echo "Searching Lazarus projects in: $search_dir"
    echo
    while IFS= read -r lpi; do
        echo "========================================"
        echo "Building project: $lpi"
        $LAZBUILD_WIN64_ALIAS "$lpi"
        echo
        $LAZBUILD_LINUX_ALIAS "$lpi"
        echo "========================================"
        echo
    done < <(find "$search_dir" -type f -name "*.lpi")
}