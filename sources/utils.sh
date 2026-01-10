#!/bin/bash

function delete_dir(){
    local target_dir="$1"
    [[ ! -d "$target_dir" ]] && return 0
    case "$target_dir" in
        "/"|"/home"|"/root"|"/usr"|"/bin"|"/etc"|"/var")
            echo "❌ Refusing to delete protected system directory: $target_dir"
            return 1
        ;;
    esac
    rm -rf "$target_dir"
}

function empty_dir(){
    local target_dir="$1"
    [[ -d "$target_dir" ]] && delete_dir $target_dir
    mkdir $target_dir
    return $?
}

function git_sync_dir(){
    local target_dir="$1"
    local repo_url="$2"
    local branch="$3"
    if [[ ! -d "$target_dir/.git" ]]; then
        delete_dir "$target_dir"
        git clone --branch "$branch" "$repo_url" "$target_dir"
    else
        pushd $(pwd) >/dev/null
        cd "$target_dir"
        git fetch origin
        git checkout "$branch"
        git reset --hard "origin/$branch"
        git clean -fdx
        popd >/dev/null
    fi
    return $?
}
