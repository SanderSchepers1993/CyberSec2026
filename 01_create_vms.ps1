# ============================================================
# CVE-2022-22947 Lab - VM Setup Script
# Host: Windows met VirtualBox
# Maakt 2 VMs aan via VDI download:
#   - Debian 11 (server/victim)
#   - Kali Linux 2025.4 (attacker)
# ============================================================

# --- CONFIGURATIE --- (Aan te passen voor eigen situatie !!!)
$VBoxManage   = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$DownloadDir  = "$env:USERPROFILE\Documents\NPEOpdracht\VDIs"
$VMDir = "D:\VM's school"

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

function Download-File($url, $dest) {
    if (Test-Path $dest) {
        Write-Host "[SKIP] Al gedownload: $dest"
        return
    }
    Write-Host "[DOWNLOAD] $url"
    Write-Host "        -> $dest"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $dest)
    Write-Host "[OK] Download klaar."
}

function Create-HostOnlyAdapter {
    # Controleer of het interne netwerk al bestaat (VirtualBox internal = geen setup nodig)
    Write-Host "[INFO] Intern netwerk '$InternalNet' wordt gebruikt (geen setup nodig bij VirtualBox internal network)."
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
        --vram 128 `
        --cpus 2 `
        --nic1 nat `
        --nic2 intnet --intnet2 $InternalNet `
        --audio none `
        --usb off

    & $VBoxManage modifyvm $name --graphicscontroller vmsvga
    & $VBoxManage modifyvm $name --accelerate3d off

    Write-Host "[OK] VM $name aangemaakt."
}

function Add-Disk($vmName, $diskPath, $sizeMB) {
    Write-Host "[DISK] VDI aanmaken voor $vmName..."
    if (Test-Path $diskPath) { Remove-Item $diskPath -Force }
    & $VBoxManage createmedium disk --filename $diskPath --size $sizeMB --format VDI
    & $VBoxManage storagectl $vmName --name "SATA" --add sata --controller IntelAhci
    & $VBoxManage storageattach $vmName --storagectl "SATA" --port 0 --device 0 --type hdd --medium $diskPath
    Write-Host "[OK] Schijf toegevoegd."
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

function Unzip-File($archief, $uitvoerMap) {
    $7zip = "C:\Program Files\7-Zip\7z.exe"
    if (-not (Test-Path $7zip)) {
        Write-Error "7-Zip niet gevonden. Installeer via: https://www.7-zip.org/"
        exit 1
    }
    Write-Host "[UNZIP] Uitpakken: $archief"
    & $7zip x $archief -o"$uitvoerMap" -y
    Write-Host "[OK] Uitgepakt naar: $uitvoerMap"
}

# ============================================================
# HOOFDSCRIPT
# ============================================================

Write-Host "============================================"
Write-Host " CVE-2022-22947 Lab - VM Setup"
Write-Host "============================================"

Check-VBoxInstalled

# Download directory aanmaken
New-Item -ItemType Directory -Force -Path $DownloadDir | Out-Null

# --- STAP 1: Debian 12 VDI downloaden en uitpakken ---
$Debian7z  = Join-Path $DownloadDir "debian12.4.7z"
$DebianVDI = Join-Path $DownloadDir "64bit\Debian 12.4.0 (64bit).vdi"

#Download-File $DebianVDI_URL $debian

if (-not (Test-Path $DebianVDI)) {
    Unzip-File $Debian7z $DownloadDir
}

# --- STAP 2: Kali Linux VDI downloaden en uitpakken ---
$Kali7z  = Join-Path $DownloadDir "kali-linux.7z"
$KaliVDI   = Join-Path $DownloadDir "kali-linux-2026.1-virtualbox-amd64\kali-linux-2026.1-virtualbox-amd64.vdi"

#Download-File $KaliVDI_URL $kali-linux

if (-not (Test-Path $KaliVDI)) {
    Unzip-File $Kali7z $DownloadDir
}

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
Write-Host "   - Gebruik statisch IP: 192.168.56.10 op adapter 2 (intnet)"
Write-Host "   - Hostname: victim"
Write-Host "   - Stel SSH in tijdens installatie"
Write-Host ""
Write-Host "2. Na installatie: voer setup_server.sh uit op de Debian VM"
Write-Host "   (zie 02_setup_server.sh)"
Write-Host ""
Write-Host "3. Start '$AttackerVMName':"
Write-Host "   - Standaard credentials: kali / kali"
Write-Host "   - Stel IP in op 192.168.56.20 op adapter 2"
Write-Host "   - Voer exploit uit met 03_exploit.py of 04_exploit_loop.sh"
Write-Host ""
Write-Host "NETWERK SCHEMA:"
Write-Host "  Victim  (Debian): 192.168.56.10 - poort 8080 (Spring Gateway)"
Write-Host "  Kali (Attacker):  192.168.56.20"
Write-Host ""
