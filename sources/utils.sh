#!/bin/bash

# Safely deletes a directory if it exists.
# Protects critical system directories from being accidentally removed.
#
# The function checks if the given path exists and is a directory.
# If the directory is listed as protected (e.g., /, /home, /root, /usr, etc.),
# the deletion is refused and an error is returned.
#
# Arguments:
#   $1 - Target directory to delete
#
# Returns:
#   0 if the directory does not exist or was successfully deleted
#   1 if the directory is protected and deletion is refused

delete_dir(){
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

# Recreates a directory by deleting it if it exists and then creating it again.
# Effectively ensures that the directory exists and is empty.
#
# If the directory already exists, it will be removed using delete_dir().
# Then a new empty directory is created at the same path.
#
# Arguments:
#   $1 - Target directory
#
# Returns:
#   Exit code of the last executed command (mkdir or delete_dir)

empty_dir(){
    local target_dir="$1"
    [[ -d "$target_dir" ]] && delete_dir $target_dir
    mkdir $target_dir
}

# Synchronizes a local directory with a remote Git repository.
# If the target directory is not a Git repository, it will be deleted and freshly cloned.
# If it already exists as a Git repo, it will be forcefully reset to match the specified branch.
#
# Arguments:
#   $1 - Target directory
#   $2 - Repository URL
#   $3 - Branch name
#
# Returns:
#   Exit code of the last executed Git command

git_sync_dir(){
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
}
