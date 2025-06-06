#!/bin/bash

set -e

cd $(dirname $0)

error_exit() {
    echo "${1}"
    exit 1
}

debian_install_python_virtual_environment() {
    echo "Installing Python virtual environment package on Debian"

    sudo apt update || error_exit "[!] Failed to apt update"
    sudo apt upgrade || error_exit "[!] Failed to apt upgrade"
    sudo apt autoremove || error_exit "[!] Failed to apt autoremove"

    sudo apt install python3.11-venv \
        || error_exit "[!] Failed to install python3.11-venv"
}

install_python_virtual_environment() {
    local -r distro_name="$(grep '^NAME=' /etc/os-release | cut -d = -f 2)"

    if [ "\"Debian GNU/Linux\"" == "${distro_name}" ] ; then
        debian_install_python_virtual_environment
        return
    fi

    error_exit "Unsupported Unix-like distribution: ${distro_name}"
}

main() {
    local -r ansible_core_version="2.18.6"

    source ./config.sh || error_exit "Failed to load config."

    install_python_virtual_environment

    python3 -m venv ${VENV_DIRECTORY} \
        || error_exit "[!] Failed to create Python virtual environment."

    source ${VENV_DIRECTORY}/bin/activate \
        || error_exit "[!] Failed to activate Python virtual environment."

    python3 -m pip -V \
        || error_exit "[!] Failed to print Pip version information."

    python3 -m pip install ansible-core==${ansible_core_version} \
        || error_exit "[!] Failed to install ansible-core."

    ansible --version \
        || error_exit "[!] Failed to print Ansible version."

    deactivate \
        || error_exit "[!] Failed to deactivate Python virtual environment."
}

main "${@}"
