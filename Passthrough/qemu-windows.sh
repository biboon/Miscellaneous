#!/bin/bash
[ "$EUID" -eq 0 ] || exec su -c "$0 $@"


SSD=/dev/disk/by-id/ata-KINGSTON_SKC400S37256G_50026B725C035E90
HDD=/dev/disk/by-id/ata-ST1000DL002-9TT153_W1V12GHP
OVMF_CODE=/usr/share/ovmf/x64/OVMF_CODE.fd
OVMF_VARS=/usr/share/ovmf/x64/OVMF_VARS.fd
WIN_ISO=/home/biboon/Documents/ISOs/Win10_Edu_1709_EnglishInternational_x64.iso
VIRTIO_ISO=/home/biboon/Documents/ISOs/virtio-win-0.1.126.iso


xrandr \
--output HDMI1 --off \
--output HDMI2 --mode 1920x1080 --pos 0x0 --rotate normal --primary

cp /home/biboon/.config/pulse/cookie /root/.config/pulse/cookie
cp $OVMF_VARS /tmp/OVMF_VARS.fd.$$


OPTS=""
OPTS="$OPTS -nographic -nodefaults -nodefconfig -no-user-config"
OPTS="$OPTS -serial none -parallel none -display none"
OPTS="$OPTS -monitor stdio"
OPTS="$OPTS -name windows"

OPTS="$OPTS -rtc clock=host,base=localtime"

OPTS="$OPTS -machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off"

OPTS="$OPTS -drive if=pflash,format=raw,readonly,file=$OVMF_CODE"
OPTS="$OPTS -drive if=pflash,format=raw,file=/tmp/OVMF_VARS.fd.$$"

OPTS="$OPTS -drive if=virtio,format=raw,cache=none,aio=native,media=disk,file=$SSD"
OPTS="$OPTS -drive if=virtio,format=raw,cache=none,aio=native,media=disk,file=$HDD"

OPTS="$OPTS -enable-kvm"
OPTS="$OPTS -cpu host,kvm=off,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv_vendor_id=Nvidia43FIX"
OPTS="$OPTS -smp 8,sockets=1,cores=4,threads=2 -m 10G"

OPTS="$OPTS -boot c"
#OPTS="$OPTS -boot d"

OPTS="$OPTS -netdev user,id=vmnic -device virtio-net-pci,netdev=vmnic"

OPTS="$OPTS -device vfio-pci,host=01:00.0,multifunction=on"
OPTS="$OPTS -device vfio-pci,host=01:00.1"

#OPTS="$OPTS -vga qxl -spice port=5900,addr=127.0.0.1,disable-ticketing"

#OPTS="$OPTS -drive index=0,media=cdrom,readonly,file=$WIN_ISO"
#OPTS="$OPTS -drive index=1,media=cdrom,readonly,file=$VIRTIO_ISO"

OPTS="$OPTS -usb"
OPTS="$OPTS -device usb-host,vendorid=0x2516,productid=0x0011"
OPTS="$OPTS -device usb-host,vendorid=0x1038,productid=0x1361"

OPTS="$OPTS -k fr -soundhw hda"


QEMU_AUDIO_DRV=pa QEMU_PA_SAMPLES=1024 QEMU_PA_SERVER=/run/user/1000/pulse/native qemu-system-x86_64 $OPTS


rm -f /tmp/OVMF_VARS.fd.$$

xrandr \
--output HDMI1 --mode 2560x1440 --pos 0x0 --rotate normal --primary \
--output HDMI2 --off


exit 0

