#!/bin/bash

[[ -n ${GITLAB_RUNNER_SOURCED:-} ]] && return 0
GITLAB_RUNNER_SOURCED=1

install_gitlab_runner_for_astra(){
    install -d -m 0755 /usr/share/keyrings
    curl -fsSL https://packages.gitlab.com/runner/gitlab-runner/gpgkey \
    | gpg --dearmor --batch --yes \
    -o /usr/share/keyrings/runner_gitlab-runner-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/runner_gitlab-runner-archive-keyring.gpg] \
    https://packages.gitlab.com/runner/gitlab-runner/debian buster main" \
    | tee /etc/apt/sources.list.d/runner_gitlab-runner.list >/dev/null
}

install_gitlab_runner_linux(){
    local target_dir="$1"

    [[ ! -d "$target_dir" ]] && mkdir "$target_dir"
    pushd $(pwd) >/dev/null
    cd "$target_dir"

    # Download the repository configuration script:
    local script_name="script.deb.sh"
    curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" -o "$script_name"

    # Run the script
    bash "$script_name"
    popd >/dev/null
    delete_dir "$target_dir"
}

install_gitlab_runner(){
    if [[ "$LINUX_VERSION" = "astra" ]]; then
        install_gitlab_runner_for_astra
    else
        install_gitlab_runner_for_linux "$1"
    fi
    $APT_COMMAND install -y gitlab-runner || exit 1
}
