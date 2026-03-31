# CyberSec2026

## Installation Vagrant

1. https://developer.hashicorp.com/vagrant/install
2. Follow the installation instructions for your OS.

## Installation Git

1. https://git-scm.com/install/windows
2. Follow the installation instructions for your OS.

## Add the github repository to your Visual Studio Code

1. Open a terminal (ctrl + ù) in VSC en kloon de github repository

```sh
git clone https://github.com/SanderSchepers1993/CyberSec2026
```

3. Vanuit de directory met de vagrantfile, maak de VMs aan.

```sh
vagrant up
```

## SSH naar de VM

1. SSH vanuit de repository met de Vagrantfile naar de target VM

```sh
vagrant ssh target
```

2. SSH vanuit de repository met de Vagrantfile naar de target VM

```sh
vagrant ssh attacker
```
