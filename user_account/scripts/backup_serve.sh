#!/bin/bash

set -e

main() {
	local -r official_tar='official.tar'
	local -r database_kdbx='Database.kdbx'
	local -r directory_share_http="${HOME}/my/share_http"

	pushd "${directory_share_http}"

	tar --directory=${HOME}/my -c -v -f ${directory_share_http}/${official_tar} ./official/
	cp --verbose ${HOME}/my/data/for_programs/keepass/${database_kdbx} ./

	ip -4 -brief address show
	python3 -m http.server
	rm --verbose ./${database_kdbx}
	rm --verbose ./${official_tar}

	popd # "${directory_share_http}"
}

main "${@}"
