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
#     * Reading start of block device:
#         `dd bs=5MB count=1 if/dev/sda of=start_of_sda.bin`
readonly WIPE_BEFORE_ENCRYPTION='TRUE'

readonly OS_BLOCK_DEVICE='/dev/sda'

readonly WORKAREA_DIRECTORY='/tmp/workarea_install_arch'

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

wipe_os_block_device() {
    local -r file_zero="zero.bin"
    local -r file_start="sda_start.bin"
    local -r file_end="sda_end.bin"

    local -r encrypted_container="to_be_wiped"

    local os_block_device_size=""
    local size_file_zero=""
    local size_file_end=""

    local device_encrypted_container="/dev/mapper/${encrypted_container}"
    local device_encrypted_container_size=""

    local latest_exit=""

    if [ "TRUE" != "${WIPE_BEFORE_ENCRYPTION}" ] ; then
        echo "Skipping OS block device wiping"
        return
    fi

    echo "Wiping ${OS_BLOCK_DEVICE} with zeroes."

    hdparm --security-erase NULL ${OS_BLOCK_DEVICE}

    os_block_device_size="$(lsblk \
        --nodeps \
        --noheadings \
        --bytes \
        --output=SIZE \
        ${OS_BLOCK_DEVICE})"
    bytes_before_last5mb="$(( ${os_block_device_size} - (5000 * 1000) ))"

    # Read 5MB from the end of OS_BLOCK_DEVICE
    dd ibs=1 skip=${bytes_before_last5mb} if=${OS_BLOCK_DEVICE} of=${file_end}

    dd bs=5MB count=1 if=/dev/zero of=${file_zero}
    dd bs=5MB count=1 if=${OS_BLOCK_DEVICE} of=${file_start}

    echo "Verifying size of file containing data from end of block device."

    size_file_zero="$(stat --format=%s ${file_zero})"
    size_file_end="$(stat --format=%s ${file_zero})"
    if [ "${size_file_zero}" != "${size_file_end}" ] ; then
        echo "Size of end file: ${size_file_zero}"
        echo "Size of zero file: ${size_file_end}"
        error_exit "[!] Unexpected size for end file or zero file."
    fi

    echo "Verifying start and end of OS block device to be full of zeroes."

    diff ${file_zero} ${file_start} || latest_exit="${?}"
    if [ "0" != "${latest_exit}" ] ; then
        error_exit "[!] Head/start of OS block device is not full of zeroes."
    fi

    diff ${file_zero} ${file_end} || latest_exit="${?}"
    if [ "0" != "${latest_exit}" ] ; then
        error_exit "[!] Tail/end of OS block device is not full of zeroes."
    fi

    bytes_before_last5mb=""
    rm ${file_start}
    rm ${file_end}

    echo "Wiping ${OS_BLOCK_DEVICE} with random data."

    cryptsetup \
        open \
        --type plain \
        --key-file /dev/urandom \
        --sector-size 4096 \
        ${OS_BLOCK_DEVICE} \
        ${encrypted_container}

    if [ ! -f ${device_encrypted_container} ] ; then
        error_exit \
            "[!] Failed to create encrypted container on ${OS_BLOCK_DEVICE}"
    fi

    dd if=/dev/zero of=${device_encrypted_container} status=progress bs=5MB

    device_encrypted_container_size=$(blockdev \
        --getsize64 \
        ${device_encrypted_container})

    bytes_before_last5mb="$(( ${device_encrypted_container_size} - (5000 * 1000) ))"

    cryptsetup close ${encrypted_container}

    dd ibs=1 skip=${bytes_before_last5mb} if=${OS_BLOCK_DEVICE} of=${file_end}

    diff ${file_zero} ${file_end} || latest_exit="${?}"
    if [ "0" == "${latest_exit}" ] ; then
        error_exit \
            "[!] The end of ${OS_BLOCK_DEVICE} does not contain random data."
    fi

    echo "Printing contents of the end of ${OS_BLOCK_DEVICE} ."
    od -j ${bytes_before_last5mb} ${OS_BLOCK_DEVICE}

    rm ${file_zero}
}

# https://wiki.archlinux.org/title/Dm-crypt/Drive_preparation
prepare_os_block_device() {
    wipe_os_block_device
}

main() {
    if [ ! -d "${WORKAREA_DIRECTORY}" ] ; then
        mkdir ${WORKAREA_DIRECTORY}
    fi

    pushd ${WORKAREA_DIRECTORY}

    verify_boot_mode

    verify_network

    verify_system_clock

    prepare_os_drive

    popd # ${WORKAREA_DIRECTORY}
}

main "${@}"
