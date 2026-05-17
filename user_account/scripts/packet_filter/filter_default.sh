#!/bin/bash

main() {
	echo "Stopping docker service and socket"
	sudo systemctl stop docker
	sudo systemctl stop docker.socket

	echo "Loading nftables default config"
	sudo nft -f /etc/nftables.conf

	echo "Stopping docker service and socket"
	sudo systemctl start docker
	sudo systemctl start docker.socket
}

main "${@}"
