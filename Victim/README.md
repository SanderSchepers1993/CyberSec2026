# Victim installatie

## Start je VM op in VirtualBox

1. Log in met:

- username: osboxes
- password: osboxes.org

2. Open een terminal

3. Test of je een werkende internetverbinding hebt.

```sh
ping 8.8.8.8
```

- Indien je ping niet succesvol is, controleer of je NAT interface aanstaat.

4. Update je OS

```sh
sudo apt-get update
```

5. Installeer Git

```sh
sudo apt install -y git
```

6. Kloon je configuratiebestanden voor Kali

```sh
git clone https://github.com/SanderSchepers1993/CyberSec2026.git
```

7. Ga naar de nieuw gekloonde Victim directory

```sh
cd CyberSec2026/Victim
```

8. Voer het script 01_setup_server.sh uit met sudo privileges

```sh
sudo bash 01_setup_server.sh
```

## [TROUBLESHOOTING]

Indien je package openjdk-11-jdk niet kan vinden, kan je met onderstaande work-around nog steeds de exploit testen

![Unable to find openjdk11](/images/openjdk11.png)

1. Voer het script 02_setup_server_java17.sh uit met sudo privileges

```sh
sudo bash 02_setup_server_java17.sh
```

2. Open je service met een teksteditor:

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
