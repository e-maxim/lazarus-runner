#!/bin/bash

set -e

# Sources
SRC_ROOT="$(realpath $(dirname "${BASH_SOURCE[0]}")/..)"
source "${SRC_ROOT}/sources/enviroment_vars.sh"
source "${SRC_ROOT}/sources/utils.sh"
source "${SRC_ROOT}/sources/gitlab_runner.sh"

# Minimal dependencies required to build FPC and Lazarus from source
install_minimal_dependencies

# Install Gitlab Runner
install_gitlab_runner "${LAZARUS_INSTALL_DIR}/gitlab_runner"
