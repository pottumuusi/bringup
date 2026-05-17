#!/bin/bash

main() {
	local -r nft_config="${HOME}/my/config/nftables_inet_drop.conf"

	echo "Loading nftables config from ${nft_config}"
	sudo nft -f ${nft_config}
}

main "${@}"
