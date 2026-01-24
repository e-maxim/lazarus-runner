#!/bin/bash

install_gitlab_runner(){
    # Download the repository configuration script:
    curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" -o script.deb.sh 

    # Run the script
    bash script.deb.sh

    # Install 
    $APT_COMMAND install gitlab-runner -y || exit 1
}

