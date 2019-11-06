#!/bin/bash

#qemu-system-x86_64 -enable-kvm -m 1G -append "root=/dev/sda rdinit=/sbin/init" -serial stdio -kernel $1 -hda $2
echo "Test------------------------"
qemu-system-x86_64  -m 2G -append "root=/dev/sda rdinit=/sbin/init" -serial stdio -kernel $1  -hda $2
