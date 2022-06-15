#!/bin/bash

apt-get install p7zip-full grub2-common mtools xorriso squashfs-tools-ng


curl -L https://releases.ubuntu.com/20.04/ubuntu-20.04.4-live-server-amd64.iso -o ubuntu-20.04.iso

7z e -o. "ubuntu-20.04.iso" casper/filesystem.squashfs

sqfs2tar filesystem.squashfs | sudo docker import - "ubuntulive:base"



