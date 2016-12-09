#!/bin/bash
if [[ $EUID -ne 0 ]]
then
    echo "This script must be run as root"
    exit 1
fi

echo "Starting virtual machine"
QEMU_HDD=/dev/disk/by-id/ata-SSD9SC120GEDA_PNY1210A00013166

qemu-system-x86_64 -enable-kvm -name windows -boot order=cd \
-cpu host,kvm=off -smp sockets=1,cores=3,threads=2 -m 8G \
-device vfio-pci,host=01:00.0,multifunction=on \
-device vfio-pci,host=01:00.1 \
-usbdevice host:2516:0011 \
-usbdevice host:1e7d:2d50 \
-drive if=pflash,format=raw,readonly,file=/usr/share/ovmf/ovmf_x64.bin \
-drive file=$QEMU_HDD,format=raw,cache=none,aio=native,media=disk \
-drive file=/home/biboon/Documents/ISOs/en_windows_10_education_n_x64_dvd_6847236.iso,id=virtiocd,if=none \
-device ide-cd,bus=ide.1,drive=virtiocd

echo "Virtual machine stopped"
exit 0
# -vga none -nographic \
# -rtc base=localtime -k fr \
# -nodefaults -serial none -parallel none \
# -nodefconfig -no-user-config -vnc :1
