#!/bin/bash

set -e

cd $(dirname $0)

error_exit() {
    echo "${1}"
    exit 1
}

verify_boot_mode() {
    if [ ! -f /sys/firmware/efi/fw_platform_size ] ; then
        echo "Detected to boot in BIOS mode."
        return
    fi

    if [ "64" != $(cat /sys/firmware/efi/fw_platform_size) ] ; then
        error_exit "Only supporting 64-bit x64 UEFI. Detected non-64-bit UEFI."
    fi
}

verify_network() {
    local latest_exit=''

    ip link | grep "enp[[:digit:]]s[[:digit:]]" || latest_exit="${?}"
    if [ "0" != "${latest_exit}" ] ; then
        error_exit "Failed to detect physical ethernet device."
    fi

    echo "Testing internet connection."
    ping -c 3 archlinux.org || latest_exit="${?}"
    if [ "0" != "${latest_exit}" ] ; then
        error_exit "Failed to reach archlinux.org ."
    fi
}

verify_system_clock() {
    echo "Printing system time"
    timedatectl

    read -p "Please verify the system time validity and press enter." ans
}

main() {
    echo "Hello world!"

    verify_boot_mode

    verify_network

    verify_system_clock
}

main "${@}"
