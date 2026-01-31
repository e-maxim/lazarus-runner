#!/bin/bash

set -e

INSTALL_LAZARUS=1

# Sources
SRC_ROOT="$(realpath $(dirname "${BASH_SOURCE[0]}")/..)"
source "${SRC_ROOT}/sources/init.sh"

if [[ ! -d "$LAZARUS_DIR" || ! -f "$LAZARUS_DIR/lazbuild" ]]; then
    echo "To install Lazarus, you first need to install FPC and lazbuild. Use the script install_lazbuild.sh for this purpose."
    return 1
fi    