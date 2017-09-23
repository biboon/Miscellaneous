#!/bin/bash
[ "$EUID" -eq 0 ] || { echo "Must be root"; exit 1; }


if [ `ps aux | grep qemu-system-x86_64 | wc -l` -gt 1 ]
then
    read -p "An instance of qemu-system-x86_64 is already running. Continue ? [Y/n] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy\n]$ ]] || exit 1
fi


xrandr \
--output HDMI-1 --off \
--output HDMI-2 --mode 1920x1080 --pos 0x0 --rotate normal --primary


echo "Starting virtual machine"


export QEMU_AUDIO_DRV=alsa
#export QEMU_ALSA_DAC_BUFFER_SIZE=1024 QEMU_ALSA_DAC_PERIOD_SIZE=256
#export QEMU_AUDIO_DAC_FIXED_SETTINGS=1
#export QEMU_AUDIO_DAC_FIXED_FREQ=48000 QEMU_AUDIO_DAC_FIXED_FMT=S16
#export QEMU_AUDIO_DAC_TRY_POLL=1
#export QEMU_AUDIO_TIMER_PERIOD=50

SSD=/dev/disk/by-id/ata-SSD9SC120GEDA_PNY1210A00013166
HDD=/dev/disk/by-id/ata-ST1000DL002-9TT153_W1V12GHP
OVMF=/usr/share/ovmf/ovmf_code_x64.bin
OVMF_VARS=/usr/share/ovmf/ovmf_vars_x64.bin
WIN_ISO=/home/biboon/Documents/ISOs/en_windows_10_education_n_x64_dvd_6847236.iso
VIRTIO_ISO=/home/biboon/Downloads/virtio-win-0.1.126.iso


COMMAND=qemu-system-x86_64

COMMAND="taskset EE $COMMAND -name windows -enable-kvm"
COMMAND="$COMMAND -nographic -nodefaults -nodefconfig -no-user-config -serial none -parallel none"

COMMAND="$COMMAND -machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off"
COMMAND="$COMMAND -cpu host,kvm=off -smp sockets=1,cores=3,threads=2 -m 8G"
COMMAND="$COMMAND -netdev user,id=vmnic -device e1000,netdev=vmnic"
COMMAND="$COMMAND -localtime -k fr -soundhw ac97"

COMMAND="$COMMAND -drive if=pflash,format=raw,readonly,file=$OVMF"
COMMAND="$COMMAND -drive if=pflash,format=raw,file=$OVMF_VARS"

COMMAND="$COMMAND -drive if=virtio,format=raw,cache=none,aio=native,media=disk,file=$SSD"
COMMAND="$COMMAND -drive if=virtio,format=raw,cache=none,aio=native,media=disk,file=$HDD"

COMMAND="$COMMAND -boot order=c"
COMMAND="$COMMAND -vga none"
COMMAND="$COMMAND -device vfio-pci,host=01:00.0,multifunction=on"
COMMAND="$COMMAND -device vfio-pci,host=01:00.1"

#COMMAND="$COMMAND -boot order=d"
#COMMAND="$COMMAND -vga qxl -spice port=5900,addr=127.0.0.1,disable-ticketing"
#COMMAND="$COMMAND -drive index=0,media=cdrom,readonly,file=$WIN_ISO"
#COMMAND="$COMMAND -drive index=1,media=cdrom,readonly,file=$VIRTIO_ISO"

COMMAND="$COMMAND -usbdevice host:2516:0011"
COMMAND="$COMMAND -usbdevice host:1038:1361"

eval $COMMAND


echo "Virtual machine stopped"


xrandr \
--output HDMI-1 --mode 2560x1440 --pos 0x0 --rotate normal --primary \
--output HDMI-2 --off


exit 0

