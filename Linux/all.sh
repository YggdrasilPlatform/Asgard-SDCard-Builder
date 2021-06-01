#!/bin/bash

set +x

if [ $# -ne 1 ]
then
    echo "Usage: $0 [drive]"
    echo "  e.g $0 /dev/sdb"
    exit 1
fi

if [ -z ${CROSS_COMPILER+x} ]
then
    >&2 echo "CROSS_COMPILER variable is not set. Make sure to set it to /path/to/arm-linux-gnueabihf-"
    exit 1
fi

sh get.sh
sh build.sh
sh flash.sh $1
