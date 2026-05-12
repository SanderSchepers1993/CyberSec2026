#!/bin/bash
# ============================================================
# CVE-2022-22947 Lab - Victim Server Setup
# Uitvoeren op: Debian 12 (victim VM)
# Installeert: Java 11, Maven, kwetsbare Spring Cloud Gateway 3.1.0
# ============================================================
 
set -e  # Stop bij eerste fout
 
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
 
log()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
info() { echo -e "${BLUE}[*]${NC} $1"; }
 
echo ""
echo "============================================"
echo " CVE-2022-22947 Victim Server Setup"
echo " Debian 12 - Spring Cloud Gateway 3.1.0"
echo "============================================"
echo ""
 
# Root check
if [ "$EUID" -ne 0 ]; then
    err "Voer dit script uit als root: sudo bash $0"
fi
 
# --- STAP 1: Systeem updaten ---
log "Systeem updaten..."
apt-get update -qq
apt-get upgrade -y -qq
 
# --- STAP 2: Java 11 installeren ---
log "Java 11 (OpenJDK) installeren..."
apt-get install -y openjdk-11-jdk curl wget unzip git net-tools
 
java -version 2>&1 | grep "11" && log "Java 11 OK" || err "Java 11 installatie mislukt"
 
# Java 17 als standaard instellen
update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java 2>/dev/null || true
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> /etc/environment
 
# --- STAP 3: SSH installeren en configureren ---
log "SSH server installeren..."
apt-get install -y openssh-server
 
# SSH inschakelen en starten
systemctl enable ssh
systemctl start ssh
 
# Controleer of SSH draait
if systemctl is-active --quiet ssh; then
    log "SSH server actief op poort 22"
else
    warn "SSH server kon niet gestart worden. Controleer: systemctl status ssh"
fi
 
# --- STAP 4: Maven installeren ---
log "Maven installeren..."
apt-get install -y maven
mvn -version | grep "Apache Maven" && log "Maven OK" || err "Maven installatie mislukt"
 
# --- STAP 5: Spring Cloud Gateway 3.1.0 project aanmaken ---
log "Spring Cloud Gateway 3.1.0 project aanmaken..."
 
APP_DIR="/opt/spring-gateway"
mkdir -p $APP_DIR
cd $APP_DIR
 
# pom.xml aanmaken met kwetsbare versies
cat > pom.xml << 'POMEOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
 
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <!-- Spring Boot 2.6.1 -> kwetsbaar voor CVE-2022-22947 -->
        <version>2.6.1</version>
        <relativePath/>
    </parent>
 
    <groupId>com.lab</groupId>
    <artifactId>vulnerable-gateway</artifactId>
    <version>1.0.0</version>
    <name>Vulnerable Spring Cloud Gateway</name>
 
    <properties>
        <java.version>11</java.version>
        <!-- Spring Cloud 2021.0.0 - KWETSBAAR (2021.0.1 bevat al de patch!) -->
        <spring-cloud.version>2021.0.0</spring-cloud.version>
    </properties>
 
    <dependencies>
        <!-- Spring Cloud Gateway 3.1.0 - KWETSBAAR voor CVE-2022-22947 -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>
 
        <!-- Actuator endpoint INSCHAKELEN (vereist voor exploit) -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
 
        <!-- WebFlux (reactive) -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-webflux</artifactId>
        </dependency>
    </dependencies>
 
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <!-- 2021.0.0 = kwetsbaar, 2021.0.1 bevat de patch -->
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
 
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
POMEOF
 
# Broncode aanmaken
mkdir -p src/main/java/com/lab/gateway
mkdir -p src/main/resources
 
# Main applicatie class
cat > src/main/java/com/lab/gateway/GatewayApplication.java << 'JAVAEOF'
package com.lab.gateway;
 
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
 
@SpringBootApplication
public class GatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(GatewayApplication.class, args);
    }
}
JAVAEOF
 
# application.yml - ONVEILIGE configuratie (actuator volledig open)
cat > src/main/resources/application.yml << 'YAMLEOF'
server:
  port: 8080
 
spring:
  application:
    name: vulnerable-gateway
  cloud:
    gateway:
      # Minimale route zodat de gateway actief is
      routes:
        - id: test-route
          uri: http://httpbin.org
          predicates:
            - Path=/test/**
 
management:
  endpoint:
    gateway:
      enabled: true    # Gateway actuator INSCHAKELEN
  endpoints:
    web:
      exposure:
        include: "*"   # ALLE actuator endpoints blootstellen (ONVEILIG!)
  security:
    enabled: false     # Geen beveiliging op actuator
 
logging:
  level:
    org.springframework.cloud.gateway: DEBUG
YAMLEOF
 
log "Applicatie bouwen (kan enkele minuten duren)..."
mvn clean package -DskipTests -q
 
JAR_FILE=$(find target -name "*.jar" | head -1)
log "JAR gebouwd: $JAR_FILE"
 
# --- STAP 6: Systemd service aanmaken ---
log "Systemd service aanmaken..."
 
cat > /etc/systemd/system/spring-gateway.service << EOF
[Unit]
Description=Vulnerable Spring Cloud Gateway (CVE-2022-22947 Lab)
After=network.target
 
[Service]
Type=simple
User=root
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/java -jar $APP_DIR/$JAR_FILE
Restart=always
RestartSec=5
Environment=JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
 
[Install]
WantedBy=multi-user.target
EOF
 
systemctl daemon-reload
systemctl enable spring-gateway
systemctl start spring-gateway
 
sleep 5
 
# --- STAP 7: Netwerk configureren ---
log "Netwerk configureren (statisch IP op eth1)..."
 
# Voeg statisch IP toe voor intern netwerk (adapter 2 = eth1 in VirtualBox)
IFACE=$(ip link | grep -E "^[0-9]+: e" | awk -F': ' '{print $2}' | tail -1)
info "Tweede netwerk interface: $IFACE"
 
cat >> /etc/network/interfaces << EOF
 
# Lab intern netwerk (VirtualBox internal)
auto $IFACE
iface $IFACE inet static
    address 192.168.56.10
    netmask 255.255.255.0
EOF
 
ifup $IFACE 2>/dev/null || ip addr add 192.168.56.10/24 dev $IFACE || warn "Herstart voor IP-configuratie"
 
# --- STAP 8: Verificatie ---
log "Service status controleren..."
sleep 3
 
if systemctl is-active --quiet spring-gateway; then
    log "Spring Gateway draait!"
else
    warn "Service nog niet actief. Probeer: systemctl status spring-gateway"
fi
 
# Test actuator endpoint
sleep 5
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/gateway/routes 2>/dev/null)
if [ "$RESPONSE" = "200" ]; then
    log "Actuator endpoint bereikbaar: http://localhost:8080/actuator/gateway/routes"
else
    warn "Actuator nog niet bereikbaar (HTTP $RESPONSE). Even wachten en opnieuw proberen."
fi
 
echo ""
echo "============================================"
echo " SETUP KLAAR!"
echo "============================================"
echo ""
echo " Victim IP (intern netwerk): 192.168.56.10"
echo " Spring Gateway URL:         http://192.168.56.10:8080"
echo " Actuator routes:            http://192.168.56.10:8080/actuator/gateway/routes"
echo " Actuator refresh:           http://192.168.56.10:8080/actuator/gateway/refresh"
echo " SSH toegang (vanuit Kali):  ssh root@192.168.56.10"
echo ""
echo " Handige commando's:"
echo "   systemctl status spring-gateway"
echo "   systemctl status ssh"
echo "   journalctl -u spring-gateway -f"
echo "   curl http://localhost:8080/actuator/gateway/routes"
echo ""
echo " KLAAR voor exploit vanuit Kali: 192.168.56.20"
echo ""
