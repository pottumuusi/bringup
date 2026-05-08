#!/bin/bash

# Dependencies:
# * XML-Twig
# 	* https://metacpan.org/dist/XML-Twig
# 	* https://packages.debian.org/trixie/xml-twig-tools

set -e

main() {
	local -r webpage_url="${1}"
	local -r webpage_file="target_webpage.html"

	pushd /tmp

	curl "${webpage_url}" > ${webpage_file}
	echo ""
	xml_grep --html --nowrap title ${webpage_file}
	echo ""
	rm ${webpage_file}

	popd
}

main "${@}"
