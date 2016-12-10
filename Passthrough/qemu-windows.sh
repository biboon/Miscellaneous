echo "Starting virtual machine"
# export QEMU_PA_SAMPLES=128
# export QEMU_AUDIO_DRV=pa
QEMU_HDD=/dev/disk/by-id/ata-SSD9SC120GEDA_PNY1210A00013166
OVMF=/usr/share/ovmf/x64/ovmf_code_x64.bin
OVMF_VARS=/usr/share/ovmf/x64/ovmf_vars_x64.bin

sudo \
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
-usbdevice host:1e7d:2d50 \
-vga none -nographic \
\
-nodefaults -serial none -parallel none \
-nodefconfig -no-user-config \
-localtime -k fr

echo "Virtual machine stopped"
exit 0
