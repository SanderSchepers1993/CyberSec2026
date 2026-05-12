# ============================================================
# CVE-2022-22947 Lab - VM Setup Script
# Host: Windows met VirtualBox
# Maakt 2 VMs aan via VDI download:
#   - Debian 11 (server/victim)
#   - Kali Linux 2025.4 (attacker)
# ============================================================

# --- OMGEVINGSVARIABELEN --- (Aan te passen voor eigen situatie !!!)
$VBoxManage   = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$DownloadDir  = "E:\HOGENT\2025-26\Semester III\CyberSec & Virt\VDI"
$VMDir = "F:\CyberSec"

# Netwerk: intern netwerk zodat VMs elkaar zien maar niet buiten
$InternalNet  = "intnet"

# VM namen
$ServerVMName   = "Victim-Debian12"
$AttackerVMName = "Attacker-Kali"

# VDI download URLs (officiële Debian & OSBoxes Kali VMDK/VDI)
# Debian 11 netinstall ISO wordt gebruikt (lichter dan volledige VDI)
$DebianVDI_URL = "https://sourceforge.net/projects/osboxes/files/v/vb/14-D-b/12.4.0/64bit.7z/download"
$KaliVDI_URL = "https://cdimage.kali.org/kali-2026.1/kali-linux-2026.1-virtualbox-amd64.7z"

# RAM & schijf
$ServerRAM_MB   = 2048
$AttackerRAM_MB = 2048
$DiskSize_MB    = 20000   # 20 GB

# --- FUNCTIES ---

function Check-VBoxInstalled {
    if (-not (Test-Path $VBoxManage)) {
        Write-Error "VirtualBox niet gevonden op: $VBoxManage"
        Write-Host "Download VirtualBox via: https://www.virtualbox.org/wiki/Downloads"
        exit 1
    }
    Write-Host "[OK] VirtualBox gevonden."
}

function Create-VM($name, $ramMB, $osType) {
    Write-Host "`n[VM] Aanmaken: $name"

    # Verwijder bestaande VM indien aanwezig
    $existing = & $VBoxManage list vms | Select-String $name
    if ($existing) {
        Write-Host "[WARN] VM '$name' bestaat al. Wordt verwijderd..."
        & $VBoxManage unregistervm $name --delete 2>$null
    }

    # VM aanmaken
    & $VBoxManage createvm --name $name --ostype $osType --register --basefolder $VMDir

    # Hardware configureren
    & $VBoxManage modifyvm $name `
        --memory $ramMB `
        --vram 24 `
        --cpus 2 `
        --nic1 nat `
        --nic2 intnet --intnet2 $InternalNet `
        --audio none `
        --usb off

    & $VBoxManage modifyvm $name --graphicscontroller vmsvga
    & $VBoxManage modifyvm $name --accelerate3d off

    Write-Host "[OK] VM $name aangemaakt."
}

function Attach-VDI($vmName, $vdiPath) {
    Write-Host "[DISK] VDI koppelen aan $vmName..."
    
    # UUID resetten om conflicten te vermijden
    & $VBoxManage internalcommands sethduuid $vdiPath
    
    & $VBoxManage storagectl $vmName --name "SATA" --add sata --controller IntelAhci
    & $VBoxManage storageattach $vmName `
        --storagectl "SATA" `
        --port 0 --device 0 `
        --type hdd `
        --medium $vdiPath
    Write-Host "[OK] VDI gekoppeld: $vdiPath"
}

# ============================================================
# HOOFDSCRIPT
# ============================================================

Write-Host "============================================"
Write-Host " CVE-2022-22947 Lab - VM Setup"
Write-Host "============================================"

Check-VBoxInstalled

# --- STAP 1: Debian 12 VDI locatie ---
$DebianVDI = Join-Path $DownloadDir "Debian 12.4.0 (64bit).vdi"

# --- STAP 2: Kali Linux VDI locatie ---
$KaliVDI   = Join-Path $DownloadDir "kali-linux-2026.1-virtualbox-amd64.vdi"

# --- STAP 3: Debian VM aanmaken ---
Create-VM $ServerVMName $ServerRAM_MB "Debian_64"
Attach-VDI $ServerVMName $DebianVDI

# --- STAP 4: Kali VM aanmaken ---
Create-VM $AttackerVMName $AttackerRAM_MB "Debian_64"
Attach-VDI $AttackerVMName $KaliVDI

# --- STAP 5: Samenvatting ---
Write-Host "`n============================================"
Write-Host " KLAAR! Volgende stappen:"
Write-Host "============================================"
Write-Host ""
Write-Host "1. Start '$ServerVMName':"
Write-Host "2. Na installatie: voer 01_setup_server.sh uit op de Debian VM"
Write-Host "3. Wacht totdat de volledige installatie van de Victim VM doorlopen is voordat je aan de AttackerVM begint"
Write-Host "4. Start '$AttackerVMName':"
Write-Host "5. Volg de stappen in Readme.md"
Write-Host ""
Write-Host ""
Write-Host "NETWERK SCHEMA:"
Write-Host "  Victim  (Debian): 192.168.56.10 - poort 8080 (Spring Gateway)"
Write-Host "  Kali (Attacker):  192.168.56.20"
Write-Host ""
