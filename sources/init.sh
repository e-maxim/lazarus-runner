#!/bin/bash

[[ -n ${INIT_SOURCED:-} ]] && return 0
INIT_SOURCED=1

source "${SRC_ROOT}/sources/enviroment_vars.sh"
source "${SRC_ROOT}/sources/utils.sh"

# Minimal dependencies required to build FPC, Gitlab Runner and Lazarus from source
install_minimal_dependencies

