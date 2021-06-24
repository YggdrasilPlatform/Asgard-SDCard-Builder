#!/bin/bash

set +x

if [ $# -ne 1 ]
then
    echo "Usage: $0 [drive]"
    echo "  e.g $0 /dev/sdb"
    exit 1
fi

DRIVE_PATH=$1

sudo umount ${DRIVE_PATH}[1-9]
FSBL1=${DRIVE_PATH}1
FSBL2=${DRIVE_PATH}2
SSBL=${DRIVE_PATH}3
ROOTFS=${DRIVE_PATH}4

ROOTFS_MOUNT=/media/asgard_rootfs

sudo mkdir -p ${ROOTFS_MOUNT}
sudo mount ${ROOTFS} ${ROOTFS_MOUNT}

echo "Flashing u-boot..."

sudo dd if=./asgard_u-boot/spl/u-boot-spl.stm32 of=${FSBL1}
sudo dd if=./asgard_u-boot/spl/u-boot-spl.stm32 of=${FSBL2}
sudo dd if=./asgard_u-boot/u-boot.img of=${SSBL}

echo "Copying Kernel image..."

sudo cp -v ./asgard_linux/arch/arm/boot/zImage ${ROOTFS_MOUNT}/boot

echo "Copying Device Tree Blobs..."

sudo mkdir -p ${ROOTFS_MOUNT}/boot/dtbs/kernel
sudo cp -v ./asgard_linux/arch/arm/boot/dts/stm32mp*.dtb ${ROOTFS_MOUNT}/boot/dtbs/kernel/

echo "Syncing..."
sync

sudo umount ${ROOTFS_MOUNT}

echo "Flashing successful!"

sudo rm -rf ${ROOTFS_MOUNT}

exit 0
