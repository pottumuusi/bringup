#!/bin/bash

set -e

cd $(dirname $0)

readonly PHASE_INSTALL_ANSIBLE="true"

main() {
    echo "Provisioning $(hostname)"

    source ./util.sh || error_exit "Failed to load util functions."
    source ./config.sh || error_exit "Failed to load config."

    assert_variable "VENV_DIRECTORY"

    if [ "true" == "${PHASE_INSTALL_ANSIBLE}" ] ; then
        echo "Installing Ansible"
        ./install_ansible.sh || error_exit "Failed to install Ansible"
    fi

    source ${VENV_DIRECTORY}/bin/activate \
        || error_exit "Failed to activate Python virtual environment."

    ansible-playbook                                  \
        ./playbooks/provision_debian_desktop_host.yml \
        --connection=local                            \
        --verbose                                     \
        --ask-become-pass

    deactivate \
        || error_exit "Failed to deactivate Python virtual environment."

    # TODO Remove virtual environment where Ansible has been installed.
    # If Ansible is required afterwards, install it to
    # my/tools/ansible/.venv in the playbook.
}

main "${@}"
