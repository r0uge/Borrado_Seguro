#!/bin/bash
# Autor: Agustin Alvarez
# Descripcion: Script para el borrado seguro de discos locales magneticos, SSD y NVMe 
# Requiere tener instalado:  nvme-cli, hdparm, coreutils (shred)
# Version: 1.1 (30/07/2024)

# Function to check if a disk supports Secure Erase (hdparm)#!/bin/bash

# Verificar si shred está instalado
if ! command -v shred &> /dev/null
then
    echo "SHRED no está instalado. Por favor, instálalo e intenta de nuevo."
    exit 1
fi

# Verificar si nvme-cli está instalado
if ! command -v nvme &> /dev/null
then
    echo "NVMe CLI no está instalado. Por favor, instálalo e intenta de nuevo."
    exit 1
fi

# Verificar si hdparm está instalado
if ! command -v hdparm &> /dev/null
then
    echo "HDPARM no está instalado. Por favor, instálalo e intenta de nuevo."
    exit 1
fi

# Function to check if a disk supports Secure Erase (hdparm)
supports_secure_erase() {
    local disk=$1
    hdparm -I /dev/$disk 2>/dev/null | grep -q "supported: Enhanced"
    return $?
}

# Function to perform Secure Erase with hdparm
secure_erase() {
    local disk=$1
    echo "Performing Secure Erase on /dev/$disk..."
    hdparm --user-master u --security-set-pass p /dev/$disk
    hdparm --user-master u --security-erase p /dev/$disk
}

# Function to perform shredding with shred
shred_disk() {
    local disk=$1
    echo "Performing shred on /dev/$disk..."
    shred -v -n 3 /dev/$disk
}

# Function to perform NVMe secure erase
nvme_secure_erase() {
    local disk=$1
    echo "Performing NVMe Secure Erase on /dev/$disk..."
    nvme format /dev/$disk
}

# Identify local disks and exclude USB drives
local_disks=$(lsblk -dno NAME,TYPE,TRAN | grep -E 'disk\s+(\?|sata|nvme)' | awk '{print $1}')

for disk in $local_disks; do
    echo "Processing /dev/$disk..."

    # Check if the disk is NVMe
    if [[ $disk == nvme* ]]; then
        nvme_secure_erase $disk
    else
        # Check if disk supports Secure Erase
        if supports_secure_erase $disk; then
            secure_erase $disk
        else
            # Check if the disk is rotational (HDD)
            is_rotational=$(cat /sys/block/$disk/queue/rotational)
            if [[ $is_rotational -eq 1 ]]; then
                shred_disk $disk
            else
                echo "/dev/$disk is an SSD but does not support Secure Erase."
            fi
        fi
    fi
done

echo "Disk wiping process completed."
read -n 1 -r -s -p $'Press enter to reboot...\n'
reboot