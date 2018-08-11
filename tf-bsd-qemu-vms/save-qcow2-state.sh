#!/bin/sh

# This file is just for convinient download of ISOs, before I make VMs
img="$(pwd)/img"

rm "$img"/freebsd11.2-compressed.qcow2
rm "$img"/openbsd6.3-compressed.qcow2
rm "$img"/netbsd8.0-compressed.qcow2
sudo qemu-img convert -O qcow2 -c /var/lib/libvirt/images/nix-freebsd-volume.qcow2 "$img"/freebsd11.2-compressed.qcow2
sudo qemu-img convert -O qcow2 -c /var/lib/libvirt/images/nix-openbsd-volume.qcow2 "$img"/openbsd6.3-compressed.qcow2
sudo qemu-img convert -O qcow2 -c /var/lib/libvirt/images/nix-netbsd-volume.qcow2  "$img"/netbsd8.0-compressed.qcow2
sudo chown "$USER":users "$img"/*
