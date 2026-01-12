#!/bin/bash

install_one_package(){
    local target_dir="$1"
    local package_path="$2"
    echo "Installing package: <$package_path>"
    pushd $(pwd) >/dev/null
    cd "$target_dir"
    ./lazbuild --add-package-link "$package_path" --primary-config-path="$target_dir" --lazarusdir="$target_dir"
    popd >/dev/null
}

install_packages(){
    local target_dir="$1"
    local packages_file="$2"
    [[ ! -f "$packages_file" ]] && return 0

    while IFS= read -r one_package_path || [[ -n "$one_package_path" ]]; do
        # trim
        one_package_path="${one_package_path#"${one_package_path%%[![:space:]]*}"}"
        one_package_path="${one_package_path%"${one_package_path##*[![:space:]]}"}"
        # skip empty
        [[ -z "$one_package_path" ]] && continue
        # skip comments
        [[ "$one_package_path" =~ ^# ]] && continue
        
        install_one_package "$target_dir" "$one_package_path"
    done < "$packages_file"
}