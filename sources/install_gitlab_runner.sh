#!/bin/bash

install_gitlab_runner(){
    local target_dir="$1"

    [[ ! -d "$target_dir" ]] && mkdir "$target_dir"
    cd "$target_dir"

    # Download the repository configuration script:
    local script_name="script.deb.sh"
    curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" -o "$script_name"

    # Run the script
    bash "$script_name"

    delete_dir "$target_dir"

    # Install 
    $APT_COMMAND install gitlab-runner -y || exit 1
}

