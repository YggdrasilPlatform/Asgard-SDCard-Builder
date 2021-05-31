#!/bin/bash

git clone https://gitlab.ti.bfh.ch/yggdrasil/asgard_u-boot.git
git clone https://gitlab.ti.bfh.ch/yggdrasil/asgard_linux.git

wget https://cdimage.ubuntu.com/ubuntu-base/releases/21.04/release/ubuntu-base-21.04-base-armhf.tar.gz -O rootfs.tar.gz
