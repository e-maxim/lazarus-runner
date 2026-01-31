#!/bin/bash

set -e

# Sources
SRC_ROOT="$(realpath $(dirname "${BASH_SOURCE[0]}")/..)"
source "${SRC_ROOT}/sources/init.sh"
source "${SRC_ROOT}/sources/gitlab_runner.sh"

# Install Gitlab Runner
install_gitlab_runner "${LAZARUS_INSTALL_DIR}/gitlab_runner"
