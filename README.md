# CyberSec2026

## Prerequisites

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Osboxes vdi](https://sourceforge.net/projects/osboxes/files/v/vb/14-D-b/12.4.0/64bit.7z/download)
- [Kali vdi](https://cdimage.kali.org/kali-2026.1/kali-linux-2026.1-virtualbox-amd64.7z)

## Voeg VBoxManage toe aan PATH

```powershell
VBoxManage --version
```

- Als VBoxManage niet gekend is, moet je deze nog toevoegen aan de omgevingsvariabelen van je OS.
- Ga naar Start, zoek vervolgens omgevingsvariabelen

![omgevingsvariabelen](/images/omgevingsvariabelen.png)

- Voeg de volgende lijn toe als omgevingsvariabele:

```powershell
C:\Program Files\Oracle\VirtualBox
```

![omgevingsvariabelen bewerken](/images/omgevingsvariabelen2.png)

- Klik 2x op Ok en probeer vervolgens opnieuw.

## Installatie Git

1. https://git-scm.com/install/windows
2. Volg de instructies voor jouw OS.

## Extract de zip files van Osboxes en Kali

1. Let erop dat de locatie waarin je de vdi's uitpakt, overeen komt met de environment variable "$DownloadDir" in [01_create_vms.ps1](01_create_vms.ps1)

## Kloon de GitHub repository

1. Open een terminal
2. Browse naar de locatie waarin je wilt werken voor dit project.

```sh
cd <project_locatie>
```

3. Kloon de github repository

```sh
git clone https://github.com/SanderSchepers1993/CyberSec2026.git
```

## Start de VM installatie

Vanuit je project directory, voer het volgende commando uit:

```powershell
./01_create_vms.ps1
```

## Post-installatie Debian victim

- [Victim/](./Victim/README.md): Documentatie voor post-installatie

## Post-installatie Kali attacker

- [Attacker/](./Attacker/README.md): Documentatie voor post-installatie
