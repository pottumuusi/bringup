#!/bin/bash

set -e

cd $(dirname $0)

main() {
    echo "Hello world!"
}

main "${@}"
