#!/bin/bash

function is_system_dir(){
    local target_dir="$1"
    if [ -d "$target_dir" ]; then
        case "$target_dir" in
            "/"|"/home"|"/root"|"/usr"|"/bin"|"/etc"|"/var")
                return 0
            ;;
        esac
    fi
    return 1
}

function clean_dir(){
    local target_dir="$1"
    if is_system_dir "$target_dir"; then
        echo "❌ Refusing to clean protected system directory: $target_dir"
        return 1
    fi
    if [ -d "$target_dir" ]; then
        rm -rf "$target_dir"/* "$target_dir"/.[!.]* "$target_dir"/..?*
    fi
    return $?
}

function delete_dir(){
    local target_dir="$1"
    if is_system_dir "$target_dir"; then
        echo "❌ Refusing to delete protected system directory: $target_dir"
        return 1
    fi
    rm -rf "$target_dir"
    return $?
}

function create_empty_dir(){
    local target_dir="$1"
    if [ -d "$target_dir" ]; then
        clean_dir $target_dir
    else
        mkdir $target_dir
    fi
    return $?
}

function git_sync_dir(){
    local target_dir="$1"
    local repo_url="$2"
    local branch="$3"
    if [ ! -d "$target_dir/.git" ]; then
        clean_dir "$target_dir"
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
