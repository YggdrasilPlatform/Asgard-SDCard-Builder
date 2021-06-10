# Linux SD Card Builder

This project provides build scripts to easily compile u-boot and Linux and flash it onto a SD Card.

## Usage

Make sure to replace `/dev/sdX` with the actual device file of your SD Card.

```
export CROSS_COMPILER="/opt/yggdrasil/asgard/bin/arm-linux-gnueabihf-"
sudo -E ./all.sh /dev/sdX
```

This will clone u-boot and Linux, compile it using the yggdrasil toolchain and then flash the generated image to `/dev/sdX`.

## Partial builds

When debugging it's often helpful to only do partial compilation or partial reflash. For this, use the following scripts:

- `./build_dts.sh` : Recompile only the u-boot and Linux device tree
- `./flash_no_rootfs.sh` : Reflashes u-boot and install the Linux kernel and device tree to the rootfs without reformatting the SD card and copying the rootfs again.
