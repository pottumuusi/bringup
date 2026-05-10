#!/bin/bash

set -e

main() {
	local -r official_tar='official.tar'
	local -r database_kdbx='Database.kdbx'
	local -r share_http_directory="${HOME}/share_http"

	pushd "${share_http_directory}"

	tar --directory=${HOME}/my cvf ${share_http_directory}/${official_tar} ./official/
	cp --verbose ./data/for_programs/keepass/${database_kdbx} ./

	ip addr
	python3 -m http.server
	rm --verbose ${database_kdbx}
	rm --verbose ${official_tar}

	popd # "${share_http_directory}"
}

main "${@}"
