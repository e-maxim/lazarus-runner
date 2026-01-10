#!/bin/bash

set -e

SRC_ROOT="$(realpath $(dirname "${BASH_SOURCE[0]}")/..)"
source "${SRC_ROOT}/sources/utils.sh"
source "${SRC_ROOT}/sources/bootstrap.sh"
source "${SRC_ROOT}/sources/compile.sh"
source "${SRC_ROOT}/sources/packages.sh"

INSTALL_DIR=/opt
PACKAGE_LIST_FILENAME="${SRC_ROOT}/scripts/packages_list.txt"
POST_INSTALL_SCRIPT="${SRC_ROOT}/scripts/postinstall.sh"

# FPC Sources
FPC_DIR=$INSTALL_DIR/fpc
FPC_FULLVERSION=3.2.3
FPC_GIT_BRANCH=fixes_3_2
FPC_GIT_REPO=https://github.com/fpc/FPCSource.git

# Lazarus Sources
LAZARUS_DIR=$INSTALL_DIR/lazarus
LAZARUS_GIT_BRANCH=fixes_4
LAZARUS_GIT_REPO=https://gitlab.com/freepascal.org/lazarus/lazarus.git

# Minimal dependencies for building FPC and Lazarus from source
apt update
apt upgrade -y
apt install -y wget binutils gcc unzip git libgl-dev libgtk2.0-0 libgtk2.0-dev
# remove FPC if it exists
apt purge 'fp-*' fpc -y
apt autoremove --purge -y

# get the FPC Sources
git_sync_dir $FPC_DIR $FPC_GIT_REPO $FPC_GIT_BRANCH

# get the Lazarus Sources
git_sync_dir $LAZARUS_DIR $LAZARUS_GIT_REPO $LAZARUS_GIT_BRANCH

# install latest FPC bootstrap that is known to work with building lazarus (or lazbuild).
install_fpc_bootstrap $INSTALL_DIR

# compile FPC for Win64
compile_win64_fpc $FPC_DIR

# compile FPC for Linux
compile_linux_fpc $FPC_DIR

# remove FPC bootstrap
uninstall_fpc_bootstrap $INSTALL_DIR

# this will link all compiled units from above into /fpc/units/[x86_64-linux | x86_64-win64]
make_links_to_units $FPC_DIR $FPC_FULLVERSION

# create bin folder and link all binary files of FPC into their specific platform folders /fpc/bin/[x86_64-linux | x86_64-win64]
# also create links of the binaries to /usr/bin/
make_links_to_bin $FPC_DIR $FPC_FULLVERSION

# set unit path relative to $FPC_DIR and make it globally known to future fpc calls
fpcmkcfg -d basepath=$FPC_DIR -o /etc/fpc.cfg

# compile lazbuild: https://wiki.freepascal.org/lazbuild
compile_linux_lazbuild $LAZARUS_DIR

# make some aliases: lazbuildl64 for linux and lazbuildw64 for win64
make_lazbuild_aliases $LAZARUS_DIR

# install packages
install_packages $LAZARUS_DIR $PACKAGE_LIST_FILENAME

# post-install script
if [ -f "$POST_NSTALL_SCRIPT" ]; then
     chmod +x $POST_NSTALL_SCRIPT
     . "$POST_INSTALL_SCRIPT"
fi
