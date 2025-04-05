#!/bin/bash

set -e

cd $(dirname $0)

# TODO
# * [ ] disable systemd timer fstrim.timer
#     * TRIM causes emptying SSD blocks, so the random data should be replaced
#       with zeroes. Random data is indistinguishable from encrypted drive data.
# * How to verify that secure erase left the device in erased state?
#     * `hdparm --security-erase NULL /dev/sda`
# * How to verify that the device is full of random data? Proposal:
#     1. Secure erase the drive
#     2. Verify device is full of zeroes
#     3. Wipe with random data
#     4. Verify device is not full of zeroes
#     * This proposal could be written into a script.
readonly WIPE_BEFORE_ENCRYPTION=''

error_exit() {
    echo "${1}"
    exit 1
}

verify_boot_mode() {
    echo "Verifying boot mode."

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

    echo "Verifying network connectivity."

    ip link | grep "enp[[:digit:]]s[[:digit:]]" ; latest_exit="${?}"
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
    verify_boot_mode

    verify_network

    verify_system_clock
}

main "${@}"
