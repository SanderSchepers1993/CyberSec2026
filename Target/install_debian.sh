#!/bin/bash

# Set bash options for better error handling
set -o errexit
set -o nounset
set -o pipefail

# Exit if not run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

install_updates() {
    apt-get update
    apt-get upgrade -y
    apt-get install -y curl wget net-tools vim
}

install_java() {
    :
}

install_vuln_app() {
    :
}

configure_vuln_app() {
    :
}

main() {
    install_updates
}

main