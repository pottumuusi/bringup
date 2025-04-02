#!/bin/bash

set -e

cd $(dirname $0)

# TODO delete this path if not required
readonly BRINGUP_BASE_PATH="$(pushd ../../ &> /dev/null; pwd ; popd &> /dev/null)"

main() {
    ./install_arch_pre_chroot.sh
}

main "${@}"
