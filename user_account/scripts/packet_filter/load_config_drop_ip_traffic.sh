#!/bin/bash

set -e

main() {
	local -r nft_config="${HOME}/my/config/nftables_inet_drop.conf"

	if [ ! -f "${nft_config}" ] ; then
		echo Configuration ${nft_config} not found.
		exit 1
	fi

	echo "Loading nftables config from ${nft_config}"
	sudo nft -f ${nft_config}
}

main "${@}"
