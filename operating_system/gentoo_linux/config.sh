#!/bin/bash

# Select what to setup
readonly cfg_should_setup_partitions="FALSE"

readonly cfg_should_setup_portage="TRUE"
readonly cfg_should_setup_timezone="TRUE"
readonly cfg_should_setup_locale="TRUE"
readonly cfg_should_setup_kernel="TRUE"
readonly cfg_should_setup_lvm="TRUE"
readonly cfg_should_setup_new_system="TRUE"
readonly cfg_should_setup_bootloader="TRUE"
readonly cfg_should_setup_packages="TRUE"

readonly cfg_set_efi64_grub_platform="FALSE"
readonly cfg_write_partition_using_sfdisk="TRUE"
readonly cfg_write_partition_using_sgdisk="FALSE"

# Will create grub config regardless of this option
readonly cfg_install_grub_to_disk="TRUE"

readonly main_block_device="/dev/sda"
readonly mountpoint_root="/mnt/gentoo"
readonly mountpoint_home="${mountpoint_root}/home"

# Parse stage3 tar name from webpage.
readonly frozen_stage3_release_dir="https://mirror.netcologne.de/gentoo/releases/amd64/autobuilds/current-stage3-amd64/"
readonly stage3_tar="$(curl ${frozen_stage3_release_dir}	\
	| grep stage3						\
	| grep amd64						\
	| grep tar						\
	| grep -v multilib					\
	| grep -v -e CONTENTS -e DIGESTS			\
	| cut -d ">" -f 2					\
	| cut -d "<" -f 1)"

readonly gentoo_config="${script_root}/gentoo_config"

readonly make_conf="${gentoo_config}/make.conf"

readonly lv_name_root="root2"
readonly lv_name_home="home2"
readonly lv_name_swap="swap"
readonly volgroup_name="vg01"
readonly lvm_root_partition_dev="/dev/${volgroup_name}/${lv_name_root}"
readonly lvm_home_partition_dev="/dev/${volgroup_name}/${lv_name_home}"
readonly lvm_swap_partition_dev="/dev/${volgroup_name}/${lv_name_swap}"
temp_root_partition_dev="${main_block_device}2"
temp_home_partition_dev="${main_block_device}3"
temp_swap_partition_dev="${main_block_device}4"

if [ "TRUE" == "$(cfg_should_setup_lvm)" ] ; then
	temp_root_partition_dev="${lvm_root_partition_dev}"
	temp_home_partition_dev="${lvm_home_partition_dev}"
	temp_swap_partition_dev="${lvm_swap_partition_dev}"
fi

readonly root_partition_dev="${temp_root_partition_dev}"
readonly home_partition_dev="${temp_home_partition_dev}"
readonly swap_partition_dev="${temp_swap_partition_dev}"
readonly boot_partition_dev="${main_block_device}1"
readonly lvm_partition_dev="${main_block_device}2"
unset temp_root_partition_dev
unset temp_home_partition_dev
unset temp_swap_partition_dev

readonly saved_partition_table="${gentoo_config}/saved_partition_table"
readonly gpt_partition_backup_file="sgdisk-sda.bin"

readonly root_size="14G"
readonly home_size="9995M"

readonly opt_pre_chroot="--pre-chroot"
readonly opt_chroot="--chroot"
readonly opt_full_install="--full"

# Intended to be called after having chrooted to new environment.
readonly opt_post_chroot="--post-chroot"

readonly kernel_sources_dir="/usr/src/linux"

readonly new_hostname="my_hostname"
readonly inet_if="enp0s25" # TODO read this from a command, instead of hardcoding
# readonly inet_if="wlp3s0" # TODO read this from a command, instead of hardcoding
