#!/bin/bash
[ "$EUID" -eq 0 ] || exec su -c "$0 $@"

VM_NAME=win10-vm
VM_BOOT=c # d
VM_KEYMAP=fr
VM_CORES=3
VM_THREADS=2
VM_MEMORY=10G

VM_DISKS=(
	/dev/disk/by-id/ata-KINGSTON_SKC400S37256G_50026B725C035E90
	/dev/disk/by-id/ata-ST1000DL002-9TT153_W1V12GHP
)

VM_CDROMS=(
	# /home/biboon/Documents/ISOs/Win10_Edu_1709_EnglishInternational_x64.iso
	# /home/biboon/Documents/ISOs/virtio-win-0.1.126.iso
)

VM_USBDEVS=(
	2516 0011
	1038 1361
	0403 6010
	03f0 0317
)

VM_GPU_VGA=01:00.0
VM_GPU_AUDIO=01:00.1

OVMF_CODE=/usr/share/ovmf/x64/OVMF_CODE.fd
OVMF_VARS=/usr/share/ovmf/x64/OVMF_VARS.fd


OPTS="-name $VM_NAME -boot $VM_BOOT -k $VM_KEYMAP"
OPTS="$OPTS -smp sockets=1,cores=$VM_CORES,threads=$VM_THREADS -m $VM_MEMORY"
OPTS="$OPTS -device vfio-pci,host=$VM_GPU_VGA,multifunction=on"
OPTS="$OPTS -device vfio-pci,host=$VM_GPU_AUDIO"
OPTS="$OPTS -device virtio-net-pci,netdev=vmnic"
OPTS="$OPTS -netdev tap,id=vmnic,ifname=$VM_NAME-tap,script=no,downscript=no"

for disk in "${VM_DISKS[@]}"; do
	OPTS="$OPTS -drive if=virtio,format=raw,cache=none,aio=native,media=disk,file=$disk"
done

OPTS="$OPTS -usb"
for (( i = 0; i < (( ${#VM_USBDEVS[@]} / 2 )); i++ )); do
	VID=${VM_USBDEVS[(( $i * 2     ))]}
	PID=${VM_USBDEVS[(( $i * 2 + 1 ))]}
	OPTS="$OPTS -device usb-host,vendorid=0x$VID,productid=0x$PID"
done

for cdrom in "${VM_CDROMS[@]}"; do
	OPTS="$OPTS -drive media=cdrom,readonly,file=$cdrom"
done


OPTS="$OPTS -enable-kvm"
OPTS="$OPTS -cpu host,kvm=off,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv_vendor_id=Nvidia43FIX"
OPTS="$OPTS -machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off"
OPTS="$OPTS -device intel-hda -device hda-output"
OPTS="$OPTS -rtc clock=host,base=localtime"
OPTS="$OPTS -drive if=pflash,format=raw,readonly,file=$OVMF_CODE"
OPTS="$OPTS -drive if=pflash,format=raw,file=/tmp/OVMF_VARS.fd.$$"
OPTS="$OPTS -nographic -nodefaults -nodefconfig -no-user-config"
OPTS="$OPTS -serial none -parallel none -display none"
OPTS="$OPTS -monitor stdio"
#OPTS="$OPTS -vga qxl -spice port=5900,addr=127.0.0.1,disable-ticketing"


xrandr \
--output HDMI1 --off \
--output HDMI2 --mode 1920x1080 --pos 0x0 --rotate normal --primary

ip tuntap add $VM_NAME-tap mode tap
ip link set $VM_NAME-tap up
ip link set $VM_NAME-tap master br0

cp /home/biboon/.config/pulse/cookie /root/.config/pulse/cookie
cp $OVMF_VARS /tmp/OVMF_VARS.fd.$$

#QEMU_PA_SAMPLES=1024 \
QEMU_AUDIO_DRV=pa \
QEMU_PA_SERVER=/run/user/1000/pulse/native \
QEMU_PA_LATENCY_OUT=20 \
QEMU_PA_SAMPLES=2205 \
qemu-system-x86_64 $OPTS

xrandr \
--output HDMI1 --mode 2560x1440 --pos 0x0 --rotate normal --primary \
--output HDMI2 --off

ip link del ${VM_NAME}-tap

rm -f /tmp/OVMF_VARS.fd.$$


exit 0

