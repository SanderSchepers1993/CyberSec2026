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

configure_sshd() {
    echo "Configuring SSH daemon for secure access..."
    cp /vagrant/configs/sshd_config /etc/ssh/sshd_config &> /dev/null
    systemctl restart sshd &> /dev/null
}

install_updates() {
    apt-get update
    apt-get upgrade -y
    apt-get install -y curl wget net-tools vim
}

install_java() {}

install_vuln_app() {}

configure_vuln_app() {}

main() {
    configure_sshd
    install_updates
}

main