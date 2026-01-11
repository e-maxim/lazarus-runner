#!/bin/bash

WIN64_DIR=x86_64-win64
LINUX_DIR=x86_64-linux

fpc_compiler_version(){
    local make_file="$1/installer/Makefile.fpc"
    local version=$(awk '
        /^\[package\]/ {in_package=1; next}
        /^\[/ {in_package=0}
        in_package && /^version=/ {print $2; exit}
        ' FS='=' "$make_file")
    echo "$version"    
}

compile_win64_fpc(){
    local target_dir="$1"
    pushd $(pwd) >/dev/null
    cd "$target_dir"
    empty_dir "$target_dir/$WIN64_DIR"
    make crossinstall OS_TARGET=win64 CPU_TARGET=x86_64 INSTALL_PREFIX="$target_dir/$WIN64_DIR"
    popd >/dev/null
}

compile_linux_fpc(){
    local target_dir="$1"
    pushd $(pwd) >/dev/null
    cd "$target_dir"
    empty_dir "$target_dir/$LINUX_DIR"
    make install OS_TARGET=linux CPU_TARGET=x86_64 INSTALL_PREFIX="$target_dir/$LINUX_DIR"
    popd >/dev/null
}

compile_linux_lazbuild(){
    local target_dir="$1"
    pushd $(pwd) >/dev/null
    cd "$target_dir"
    make lazbuild OS_TARGET=linux CPU_TARGET=x86_64
    popd >/dev/null
}

exists_compiler_directory(){
    local target_dir="$1"
    local fpc_version="$2"
    if [[ ! -d "$target_dir/$LINUX_DIR/lib/fpc/$fpc_version" 
        || ! -d "$target_dir/$WIN64_DIR/lib/fpc/$fpc_version" ]]; then
        echo "Directories with the full version of FPC ($fpc_version) not found, please check the correctness of the FPC git branch."
        return 1
    fi
}

make_links_to_units(){
    local target_dir="$1"
    local fpc_version="$(fpc_compiler_version $target_dir)"
    ! exists_compiler_directory "$target_dir" "$fpc_version" && return 1
    local units_dir="$target_dir/units"
    empty_dir "$units_dir"
    ln -sf "$target_dir/$LINUX_DIR/lib/fpc/$fpc_version/units/x86_64-linux" "$units_dir/$LINUX_DIR"
    ln -sf "$target_dir/$WIN64_DIR/lib/fpc/$fpc_version/units/x86_64-win64" "$units_dir/$WIN64_DIR"
}


make_links_to_bin(){
    local target_dir="$1"
    local fpc_version="$(fpc_compiler_version $target_dir)"
    ! exists_compiler_directory "$target_dir" "$fpc_version" && return 1

    local bin_dir="$target_dir/bin"
    local bin_linux_dir="$bin_dir/$LINUX_DIR"
    local bin_win64_dir="$bin_dir/$WIN64_DIR"

    empty_dir "$bin_dir"
    empty_dir "$bin_linux_dir"
    empty_dir "$bin_win64_dir"

    ln -sf "$target_dir/$LINUX_DIR/bin/"* "$bin_linux_dir"
    ln -sf "$target_dir/$LINUX_DIR/lib/fpc/$fpc_version/ppcx64" "$bin_linux_dir/ppcx64"
    ln -sf "$target_dir/$WIN64_DIR/lib/fpc/$fpc_version/ppcrossx64" "$bin_win64_dir/ppcrossx64"

    ln -sf "$bin_win64_dir/ppcrossx64" /usr/bin/ppcrossx64
    ln -sf "$bin_linux_dir/ppcx64" /usr/bin/ppcx64
    ln -sf "$bin_linux_dir/fpc" /usr/bin/fpc
    ln -sf "$bin_linux_dir/fpcmkcfg" /usr/bin/fpcmkcfg
    ln -sf "$bin_linux_dir/fpcres" /usr/bin/x86_64-win64-fpcres
}

make_lazbuild_aliases(){
    local target_dir="$1"

    # Linux
    echo "$target_dir/lazbuild --os=linux --cpu=x86_64 --primary-config-path=$target_dir --lazarusdir=$target_dir --compiler=/usr/bin/ppcx64 \$*" > "/usr/bin/$LAZBUILD_LINUX_ALIAS"
    chmod 777 "/usr/bin/$LAZBUILD_LINUX_ALIAS"

    # Win64
    echo "$target_dir/lazbuild --os=win64 --cpu=x86_64 --primary-config-path=$target_dir --lazarusdir=$target_dir --compiler=/usr/bin/ppcrossx64 --widgetset=win32 \$*" > "/usr/bin/$LAZBUILD_WIN64_ALIAS"
    chmod 777 "/usr/bin/$LAZBUILD_WIN64_ALIAS"

    # lazbuild: help
    echo "printf \"Use '$LAZBUILD_LINUX_ALIAS' for Linux and '$LAZBUILD_WIN64_ALIAS' for Windows\n\"" > /usr/bin/lazbuild
    chmod 777 /usr/bin/lazbuild
}     
