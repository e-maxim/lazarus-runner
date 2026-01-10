#!/bin/bash

if [ -z "${__COMMON_SH__}" ]; then
    __COMMON_SH__=1
    SRC_ROOT="$(realpath $(dirname "${BASH_SOURCE[0]}"))"
    source "${SRC_ROOT}/utils.sh"
    source "${SRC_ROOT}/fpc_bootstrap.sh"
    source "${SRC_ROOT}/fpc_compile.sh"
    source "${SRC_ROOT}/fpc_packages.sh"
fi
