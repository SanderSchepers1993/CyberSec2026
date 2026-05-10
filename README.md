# CyberSec2026

## Prerequisites

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Osboxes](https://sourceforge.net/projects/osboxes/files/v/vb/14-D-b/12.4.0/64bit.7z/download)
- [Kali](https://cdimage.kali.org/kali-2026.1/kali-linux-2026.1-virtualbox-amd64.7z)

## Voeg VBoxManage toe aan PATH

```powershell
VBoxManage --version
```

Als VBoxManage niet gekend is, moet je deze nog toevoegen aan je omgevingsvariabelen.

## Installatie Git

1. https://git-scm.com/install/windows
2. Volg de instructies voor jouw OS.

## Add the github repository to your Visual Studio Code

1. Open een terminal (ctrl + ù) in VSC en kloon de github repository

```sh
git clone https://github.com/SanderSchepers1993/CyberSec2026
```

## Start de VM installatie

Vanuit de root directory, voer het volgende commando uit:

```powershell
./01_create_vms.ps1
```

## Post-installatie Debian target

- [Target/](./Target/README.md): Documentatie voor post-installatie

## Post-installatie Kali attacker

- [Attacker/](./Attacker/README.md): Documentatie voor post-installatie
