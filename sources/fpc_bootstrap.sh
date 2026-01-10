#!/bin/bash

SRC_ROOT="$(realpath $(dirname "${BASH_SOURCE[0]}"))"
source "${SRC_ROOT}/utils.sh"

# FPC Compiler
FPC_PACKAGE_NAME=fpc-laz
FPC_BOOTSTRAP_NAME=fpc-laz_3.2.2-210709_amd64.deb
FPC_BOOTSTRAP=https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20amd64%20DEB/Lazarus%204.4/$FPC_BOOTSTRAP_NAME

function install_fpc_bootstrap(){
    local fpc_bootstrap_dir="$1"
    pushd $(pwd) >/dev/null
    create_empty_dir $fpc_bootstrap_dir
    cd $fpc_bootstrap_dir
    wget $FPC_BOOTSTRAP
    dpkg -i $FPC_BOOTSTRAP_NAME
    popd >/dev/null
    return $?
}

function uninstall_fpc_bootstrap(){
    local fpc_bootstrap_dir="$1"
    apt purge $FPC_PACKAGE_NAME -y
    apt autoremove --purge
    delete_dir $fpc_bootstrap_dir
    return $?
}