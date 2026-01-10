#!/bin/bash

FPC_PACKAGE_NAME=fpc-laz
FPC_BOOTSTRAP_NAME=fpc-laz_3.2.2-210709_amd64.deb
FPC_BOOTSTRAP=https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20amd64%20DEB/Lazarus%204.4/$FPC_BOOTSTRAP_NAME
FPC_BOOTSTRAP_DIR=fpc_bootstrap

function install_fpc_bootstrap(){
    local target_dir="$1/$FPC_BOOTSTRAP_DIR"
    pushd $(pwd) >/dev/null
    empty_dir $target_dir
    cd $target_dir
    wget $FPC_BOOTSTRAP
    dpkg -i $FPC_BOOTSTRAP_NAME
    popd >/dev/null
    return $?
}

function uninstall_fpc_bootstrap(){
    local target_dir="$1/$FPC_BOOTSTRAP_DIR"
    apt purge $FPC_PACKAGE_NAME -y
    apt autoremove --purge -y
    #delete_dir $target_dir
    return $?
}