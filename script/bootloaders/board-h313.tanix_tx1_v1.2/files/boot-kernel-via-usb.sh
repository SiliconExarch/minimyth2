#!/bin/sh

welcome_string="H616"

echo "Awaiting for device ..."

while true
do
    device=$(sunxi-fel -l 2>/dev/null | sed -e 's/\s*//g')
    if [[ "${device}" =~ "${welcome_string}" ]] ; then
        echo "Device discovered. Good!!!"
        break
    else
        sleep 1
        echo "Awaiting for device ..."
    fi
done

echo "Starting upload U-Boot, Linux Kernel, DTB to device ..."

sunxi-fel -v -p uboot u-boot-sunxi-with-spl.bin \
write 0x40200000 Image \
write 0x4fa00000 dtbs/allwinner/sun50i-h313-tanix-tx1.dtb \
write 0x4fc00000 load-kernel.scr \

echo "Booting Linux kernel on device. Please wait ..."

sleep 15

echo "Now you can (re)connect USB key with rootfs ..."
echo " "
