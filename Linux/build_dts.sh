#!/bin/bash

set +x

if [ -z ${CROSS_COMPILER+x} ]
then
    >&2 echo "CROSS_COMPILER variable is not set. Make sure to set it to /path/to/arm-linux-gnueabihf-"
    exit 1
fi

cd asgard_u-boot
make ARCH=arm CROSS_COMPILE=${CROSS_COMPILER} DEVICE_TREE=stm32mp157c-dk2 all -j$((`nproc`+1))
cd ..

cd asgard_linux
make ARCH=arm CROSS_COMPILE=${CROSS_COMPILER} dtbs LOADADDR=0xC2000040 -j$((`nproc`+1))
cd ..
