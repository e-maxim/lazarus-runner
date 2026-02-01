#!/bin/bash

[[ -n ${UTILS_SOURCED:-} ]] && return 0
UTILS_SOURCED=1

detect_os_params(){
    OS_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    OS_VERSION_NAME=$(grep '^VERSION_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
    OS_VERSION_ID=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    if [[ "$OS_ID" == "astra"]]; then
        APT_COMMAND="apt-get"
        APT_UPGRADE_COMMAND="dist-upgrade"
        [["$OS_VERSION_ID" == "1.7*"]] && OS_VERSION_NAME="buster"
        [["$OS_VERSION_ID" == "1.8*"]] && OS_VERSION_NAME="bookworm"
    else
        APT_COMMAND="apt"
        APT_UPGRADE_COMMAND="upgrade"
    fi
}


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
    [[ -d "$target_dir" ]] && delete_dir "$target_dir"
    mkdir "$target_dir"
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

# Installs and configures the minimal set of system dependencies required for building the project.
# This function updates the package lists, upgrades installed packages, installs required build tools
# and libraries, configures necessary system links, and removes any existing FPC installation
# to avoid potential conflicts.

install_minimal_dependencies(){
    detect_os_params
    
    $APT_COMMAND update -y || exit 1
    $APT_COMMAND $APT_UPGRADE_COMMAND -y || exit 1

    if [[ -n ${INSTALL_GITLAB_RUNNER:-} ]]; then
        # Apps for Gitlab Runner
        $APT_COMMAND install -y ca-certificates sudo less curl gnupg lsb-release || exit 1  
    fi   

    if [[ -n ${INSTALL_LAZBUILD:-} ]]; then
        # Apps for downloading and building Lazarus
        $APT_COMMAND install -y wget binutils gcc unzip git libgl-dev libgtk2.0-0 libgtk2.0-dev binutils-mingw-w64-x86-64 || exit 1
        # Adding a link to windres for compiling Windows RC files
        ln -sf /usr/bin/x86_64-w64-mingw32-windres /usr/bin/windres
        # Remove existing FPC installation if present
        $APT_COMMAND purge 'fp-*' fpc -y &> /dev/null
    fi    

    $APT_COMMAND autoremove --purge -y
}
