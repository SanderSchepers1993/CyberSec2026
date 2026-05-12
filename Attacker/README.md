# Attacker installatie

## Start je VM op in VirtualBox

1. Log in met:

- username: kali
- password: kali

1. Open een terminal

[OPTIONEEL] Update naar laatste nieuwe release 2. Test of je een werkende internetverbinding hebt.

```sh
ping 8.8.8.8
```

```sh
sudo apt-get update
```

2. Kloon je configuratiebestanden voor Kali

```sh
git clone https://github.com/SanderSchepers1993/CyberSec2026.git
```

3. Ga naar de nieuw gekloonde Attacker directory

```sh
cd CyberSec2026/Attacker
```

4. Voer kali_setup.sh uit met sudo privileges

```sh
sudo bash 01_kali_setup.sh
```
