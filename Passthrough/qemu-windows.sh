#!/bin/bash

qemu-system-x86_64 -name windows -enable-kvm -m 8096 -cpu host,kvm=off -vga none -nographic \
-smp 6,sockets=1,cores=3,threads=2 \
-rtc base=localtime \
-device vfio-pci,host=01:00.0,x-vga=on \
-device vfio-pci,host=01:00.1 \
-usb -usbdevice host:2516:0011 \
-usb -usbdevice host:1e7d:2d50 \
-drive if=pflash,format=raw,readonly,file=/usr/share/ovmf/x64/ovmf_code_x64.bin \
-drive if=pflash,format=raw,file=/usr/share/ovmf/x64/ovmf_vars_x64.bin \
-drive file=/dev/disk/by-id/ata-SSD9SC120GEDA_PNY1210A00013166,format=raw,index=0,media=disk
