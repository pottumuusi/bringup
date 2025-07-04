#!/bin/bash

set -e

cd $(dirname $0)

main() {
    echo "Provisioning $(hostname)"

    source ./util.sh || error_exit "Failed to load util functions."
    source ./config.sh || error_exit "Failed to load config."

    assert_variable "VENV_DIRECTORY"

    echo "Installing Ansible"
    ./install_ansible.sh || error_exit "Failed to install Ansible"

    source ${VENV_DIRECTORY}/bin/activate \
        || error_exit "Failed to activate Python virtual environment."

    # TODO Run provisioning Ansible playbook.

    deactivate \
        || error_exit "Failed to deactivate Python virtual environment."
}

main "${@}"
