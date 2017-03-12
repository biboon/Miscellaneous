#!/bin/bash
if [ `ps aux | grep qemu-system-x86_64 | wc -l` -gt 1 ]
then
    echo "An instance of qemu-system-x86_64 is already running... Aborting"
    exit 1
fi

echo "Starting virtual machine"
export QEMU_AUDIO_DRV=alsa
QEMU_HDD=/dev/disk/by-id/ata-SSD9SC120GEDA_PNY1210A00013166
OVMF=/usr/share/ovmf/x64/ovmf_code_x64.bin
OVMF_VARS=/usr/share/ovmf/x64/ovmf_vars_x64.bin

# Disable primary screen and set the second screen primary
xrandr \
--output HDMI1 --off \
--output HDMI2 --mode 1920x1080 --pos 0x0 --rotate normal --primary

# Run the VM, taskset for CPU pinning
sudo \
taskset EE \
qemu-system-x86_64 -enable-kvm -name windows -boot order=c \
-machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off \
-cpu host,kvm=off -smp sockets=1,cores=3,threads=2 -m 8G \
-drive if=virtio,format=raw,cache=none,aio=native,media=disk,file=$QEMU_HDD \
-device vfio-pci,host=01:00.0,multifunction=on \
-device vfio-pci,host=01:00.1 \
-netdev user,id=vmnic -device e1000,netdev=vmnic \
-drive if=pflash,format=raw,readonly,file=$OVMF \
-drive if=pflash,format=raw,file=$OVMF_VARS \
-usbdevice host:2516:0011 \
-usbdevice host:1038:1361 \
-vga none -nographic -soundhw hda \
\
-nodefaults -serial none -parallel none \
-nodefconfig -no-user-config \
-localtime -k fr

# Restore first screen as primary and the second screen as secondary
xrandr \
--output HDMI1 --mode 2560x1440 --pos 0x0 --rotate normal --primary \
--output HDMI2 --off

echo "Virtual machine stopped"
exit 0
