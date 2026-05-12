# Victim installatie

## Start je VM op in VirtualBox

1. Log in met:

- username: osboxes
- password: osboxes.org

1. Open een terminal en update je OS

```sh
sudo apt-get update
```

2. Installeer Git

```sh
sudo apt install -y git
```

3. Kloon je configuratiebestanden voor Kali

```sh
git clone https://github.com/SanderSchepers1993/CyberSec2026.git
```

3. Ga naar de nieuw gekloonde Victim directory

```sh
cd CyberSec2026/Victim
```

4. Voer het script 01_setup_server.sh uit met sudo privileges

```sh
sudo bash 01_setup_server.sh
```

## [TROUBLESHOOTING]

Indien je package openjdk-11-jdk niet kan vinden, kan je met onderstaande work-around nog steeds de exploit testen
![Unable to find openjdk11](/images/openjdk11.png)

1. Pas je service aan met volgend commando

```sh
sudo nano /etc/systemd/system/spring-gateway.service
```

2. Vervang ExecStart door het volgende

```sh
ExecStart=/usr/bin/java --add-opens java.base/java.lang=ALL-UNNAMED -jar /opt/spring-gateway/target/vulnerable-gateway-1.0.0.jar
```

- Java 17 blokkeert standaard het uitvoeren van externe java libraries
- Met het bovenstaande commando laat je java libraries buiten de Java-module toe om via reflection in java.lang te kijken.

3. Herstart de service

```sh
sudo systemctl daemon-reload
sudo systemctl restart spring-gateway
```
