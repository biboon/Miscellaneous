#!/bin/bash
if [[ $EUID -ne 0 ]]
then
    echo "This script must be run as root"
    exit 1
fi

echo "Starting virtual machine"
# export QEMU_PA_SAMPLES=128
# export QEMU_AUDIO_DRV=alsa
QEMU_HDD=/dev/disk/by-id/ata-SSD9SC120GEDA_PNY1210A00013166

qemu-system-x86_64 -enable-kvm -name windows \
-cpu host,kvm=off -smp sockets=1,cores=3,threads=2 -m 8G \
-device vfio-pci,host=01:00.0,multifunction=on \
-device vfio-pci,host=01:00.1 \
-usbdevice host:2516:0011 \
-usbdevice host:1e7d:2d50 \
-drive if=pflash,format=raw,readonly,file=/usr/share/ovmf/x64/ovmf_code_x64.bin \
-drive file=$QEMU_HDD,format=raw,index=0,media=disk \
-netdev user,id=vmnic -device e1000,netdev=vmnic \
-vga none -nographic \
\
-machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off \
-nodefaults -serial none -parallel none \
-nodefconfig -no-user-config \
-localtime -k fr

echo "Virtual machine stopped"
exit 0

# Use this to run the VM in the background
# -daemonize -pidfile file
