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

echo "Clearing drive..."

sudo sgdisk -Z ${DRIVE_PATH}

sudo dd if=/dev/zero of=${DRIVE_PATH} bs=10M count=10 status=progress
sudo sgdisk -o ${DRIVE_PATH}

echo "Creating partitions..."

sudo sgdisk --resize-table=128 -a 1 \
        -n 1:34:545     -c 1:fsbl1  \
        -n 2:546:1057   -c 2:fsbl2  \
        -n 3:1058:5153  -c 3:ssbl   \
        -n 4:5154:      -c 4:rootfs \
        -p ${DRIVE_PATH}

sudo partprobe ${DRIVE_PATH}

sudo sgdisk -A 4:set:2 ${DRIVE_PATH}

echo "Flashing u-boot..."

sudo dd if=./asgard_u-boot/spl/u-boot-spl.stm32 of=${FSBL1}
sudo dd if=./asgard_u-boot/spl/u-boot-spl.stm32 of=${FSBL2}
sudo dd if=./asgard_u-boot/u-boot.img of=${SSBL}

echo "Creating rootfs..."

sudo mkfs.ext4 -L rootfs -O ^metadata_csum,^64bit ${ROOTFS}
yes | sudo mkfs.ext4 -L rootfs ${ROOTFS}

ROOTFS_MOUNT=/media/asgard_rootfs

sudo mkdir -p ${ROOTFS_MOUNT}
sudo mount ${ROOTFS} ${ROOTFS_MOUNT}

pv rootfs.tar.gz | sudo tar -xzf - -C ${ROOTFS_MOUNT}

echo "Syncing..."
sync

echo "Setting permissions..."

sudo chown root:root ${ROOTFS_MOUNT}
sudo chmod 755 ${ROOTFS_MOUNT}

echo "Setting up extlinux.conf..."

sudo mkdir -p ${ROOTFS_MOUNT}/boot/extlinux
sudo sh -c "echo 'label Linux Kernel' > ${ROOTFS_MOUNT}/boot/extlinux/extlinux.conf"
sudo sh -c "echo 'kernel /boot/zImage' >> ${ROOTFS_MOUNT}/boot/extlinux/extlinux.conf"
sudo sh -c "echo 'append console=ttySTM0,115200 root=/dev/mmcblk0p4 ro rootfstype=ext4 rootwait vt.global_cursor_default=0' >> ${ROOTFS_MOUNT}/boot/extlinux/extlinux.conf"
sudo sh -c "echo 'fdtdir /boot/dtbs/kernel/' >> ${ROOTFS_MOUNT}/boot/extlinux/extlinux.conf"
sudo sh -c "echo 'devicetree /boot/dtbs/kernel/stm32mp157c-dk2.dtb' >> ${ROOTFS_MOUNT}/boot/extlinux/extlinux.conf"

echo "Copying Kernel image..."

sudo cp -v ./asgard_linux/arch/arm/boot/zImage ${ROOTFS_MOUNT}/boot

echo "Copying Device Tree Blobs..."

sudo mkdir -p ${ROOTFS_MOUNT}/boot/dtbs/kernel
sudo cp -v ./asgard_linux/arch/arm/boot/dts/stm32mp*.dtb ${ROOTFS_MOUNT}/boot/dtbs/kernel/

echo "Setting up fstab..."

sudo mkdir -p ${ROOTFS_MOUNT}/etc
sudo sh -c "echo '/dev/mmcblk0p4  /  auto  errors=remount-ro  0  1' >> ${ROOTFS_MOUNT}/etc/fstab"

echo "Syncing..."
sync

sudo umount ${ROOTFS_MOUNT}

echo "\nFlashing successul!"

sudo rm -rf ${ROOTFS_MOUNT}

exit 0