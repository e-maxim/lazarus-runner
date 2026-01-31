#!/bin/bash

[[ -n ${ENVIROMENT_VARS_SOURCED:-} ]] && return 0
ENVIROMENT_VARS_SOURCED=1

LAZARUS_INSTALL_DIR="${LAZARUS_INSTALL_DIR:-/opt}"
FPC_GIT_BRANCH="${FPC_GIT_BRANCH:-fixes_3_2}"
LAZARUS_GIT_BRANCH="${LAZARUS_GIT_BRANCH:-fixes_4}"
LAZBUILD_WIN64_ALIAS="${LAZBUILD_WIN64_ALIAS:-lazbuild_win64}"
LAZBUILD_LINUX_ALIAS="${LAZBUILD_LINUX_ALIAS:-lazbuild_linux}"

# FPC sources
FPC_DIR="$LAZARUS_INSTALL_DIR/fpc"
FPC_GIT_REPO=https://github.com/fpc/FPCSource.git

# Lazarus sources
LAZARUS_DIR="$LAZARUS_INSTALL_DIR/lazarus"
LAZARUS_GIT_REPO=https://gitlab.com/freepascal.org/lazarus/lazarus.git
