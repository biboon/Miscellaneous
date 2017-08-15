#!/bin/bash
[ "$EUID" -eq 0 ] || { echo "Must be root"; exit 1; }

if [ `ps aux | grep qemu-system-x86_64 | wc -l` -gt 1 ]
then
    read -p "An instance of qemu-system-x86_64 is already running. Continue ? [Y/n] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy\n]$ ]] || exit 1
fi


# Disable primary screen and set the second screen primary
xrandr \
--output HDMI-1 --off \
--output HDMI-2 --mode 1920x1080 --pos 0x0 --rotate normal --primary


echo "Starting virtual machine"
export QEMU_AUDIO_DRV=alsa
QEMU_HDD=/dev/disk/by-id/ata-SSD9SC120GEDA_PNY1210A00013166
OVMF=/usr/share/ovmf/ovmf_code_x64.bin
OVMF_VARS=/usr/share/ovmf/ovmf_vars_x64.bin

# Run the VM, taskset for CPU pinning
taskset EE \
qemu-system-x86_64 -enable-kvm -name windows -boot order=c \
-machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off \
-cpu host,kvm=off -smp sockets=1,cores=3,threads=2 -m 8G \
-drive if=pflash,format=raw,readonly,file=$OVMF \
-drive if=pflash,format=raw,file=$OVMF_VARS \
-drive if=virtio,format=raw,cache=none,aio=native,media=disk,file=$QEMU_HDD \
-netdev user,id=vmnic -device e1000,netdev=vmnic \
-device vfio-pci,host=01:00.0,multifunction=on \
-device vfio-pci,host=01:00.1 \
-usbdevice host:2516:0011 \
-usbdevice host:1038:1361 \
-usbdevice host:03f0:0317 \
\
-vga none -nographic -soundhw ac97 \
-nodefaults -serial none -parallel none \
-nodefconfig -no-user-config \
-localtime -k fr


# Restore first screen as primary and the second screen as secondary
xrandr \
--output HDMI-1 --mode 2560x1440 --pos 0x0 --rotate normal --primary \
--output HDMI-2 --off


echo "Virtual machine stopped"
exit 0

