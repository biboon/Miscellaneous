#!/bin/bash
if [[ $EUID -ne 0 ]]
then
    echo "This script must be run as root"
    exit 1
fi

echo "Starting virtual machine"
QEMU_HDD=/dev/disk/by-id/ata-SSD9SC120GEDA_PNY1210A00013166
OVMF=/usr/share/ovmf/x64/ovmf_code_x64.bin
OVMF_VARS=/usr/share/ovmf/x64/ovmf_vars_x64.bin
INSTALL_ISO=/home/biboon/Documents/ISOs/en_windows_10_education_n_x64_dvd_6847236.iso
VIRTIO_ISO=./virtio-win-0.1.126.iso

qemu-system-x86_64 -enable-kvm -name windows \
-machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off \
-cpu host,kvm=off -smp sockets=1,cores=3,threads=2 -m 8G \
-drive if=virtio,format=raw,cache=none,aio=native,media=disk,file=$QEMU_HDD \
-drive if=pflash,format=raw,readonly,file=$OVMF \
-drive if=pflash,format=raw,file=$OVMF_VARS \
-usbdevice host:2516:0011 \
-usbdevice host:1e7d:2d50

echo "Virtual machine stopped"
exit 0
# -vga none -nographic \
# -rtc base=localtime -k fr \
# -nodefaults -serial none -parallel none \
# -nodefconfig -no-user-config -vnc :1

# Pass this first
# -boot order=dc
# -drive if=none,format=raw,file=$INSTALL_ISO,id=drive \
# -device ide-cd,bus=ide.1,drive=drive \
# -drive if=none,format=raw,file=$VIRTIO_ISO,id=virtiodriver \
# -device ide-cd,bus=ide.2,drive=virtiodriver \

# Then rerun the VM with GPU
# -boot order=c
# -device vfio-pci,host=01:00.0,multifunction=on \
# -device vfio-pci,host=01:00.1 \
