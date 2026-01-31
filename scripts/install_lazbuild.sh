#!/bin/bash

set -e

# Sources
SRC_ROOT="$(realpath $(dirname "${BASH_SOURCE[0]}")/..)"
source "${SRC_ROOT}/sources/enviroment_vars.sh"
source "${SRC_ROOT}/sources/utils.sh"
source "${SRC_ROOT}/sources/fpc_bootstrap.sh"
source "${SRC_ROOT}/sources/fpc_compiler.sh"
source "${SRC_ROOT}/sources/fpc_packages.sh"
source "${SRC_ROOT}/sources/fpc_project_builder.sh"
PACKAGE_LIST_FILENAME="${SRC_ROOT}/scripts/packages_list.txt"
POST_INSTALL_SCRIPT="${SRC_ROOT}/scripts/postinstall.sh"

# FPC sources
FPC_DIR="$LAZARUS_INSTALL_DIR/fpc"
FPC_GIT_REPO=https://github.com/fpc/FPCSource.git

# Lazarus sources
LAZARUS_DIR="$LAZARUS_INSTALL_DIR/lazarus"
LAZARUS_GIT_REPO=https://gitlab.com/freepascal.org/lazarus/lazarus.git

# Minimal dependencies required to build FPC and Lazarus from source
install_minimal_dependencies

# Clone or update the FPC source repository
git_sync_dir "$FPC_DIR" "$FPC_GIT_REPO" "$FPC_GIT_BRANCH"

# Clone or update the Lazarus source repository
git_sync_dir "$LAZARUS_DIR" "$LAZARUS_GIT_REPO" "$LAZARUS_GIT_BRANCH"

# Install the latest FPC bootstrap known to work for building FPC and lazbuild
install_fpc_bootstrap "$LAZARUS_INSTALL_DIR"

# Compile FPC for Windows 64-bit
compile_win64_fpc "$FPC_DIR"

# Compile FPC for Linux
compile_linux_fpc "$FPC_DIR"

# Remove the FPC bootstrap
uninstall_fpc_bootstrap "$LAZARUS_INSTALL_DIR"

# Link all compiled units to /fpc/units/[x86_64-linux | x86_64-win64]
make_links_to_units "$FPC_DIR"

# Create the bin folder and link all FPC binaries to their platform-specific folders (/fpc/bin/[x86_64-linux | x86_64-win64])
# Also create links to these binaries in /usr/bin/
make_links_to_bin "$FPC_DIR"

# Set the unit path relative to $FPC_DIR and make it globally accessible for future FPC calls
fpcmkcfg -d basepath="$FPC_DIR" -o /etc/fpc.cfg

# Compile lazbuild (see: https://wiki.freepascal.org/lazbuild)
compile_linux_lazbuild "$LAZARUS_DIR"

# Create lazbuild aliases for Linux and for Windows 64-bit
make_lazbuild_aliases "$LAZARUS_DIR"

# Install Lazarus packages
install_packages "$LAZARUS_DIR" "$PACKAGE_LIST_FILENAME"

# Run post-install script if it exists
if [ -f "$POST_INSTALL_SCRIPT" ]; then
     bash "$POST_INSTALL_SCRIPT"
fi

# Running unit tests with projects on Lazarus that are compiled for Win64 and Linux
build_lazarus_projects "${SRC_ROOT}/tests"
