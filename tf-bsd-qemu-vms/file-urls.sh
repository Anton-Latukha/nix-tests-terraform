#!/bin/sh

# This file is just for convinient download of ISOs, before I make VMs

curl https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/11.2/FreeBSD-11.2-RELEASE-amd64-disc1.iso -o ./img/FreeBSD-11.2-amd64.iso
curl http://ftp.fr.netbsd.org/pub/NetBSD/NetBSD-8.0/iso/NetBSD-8.0-amd64.iso -o ./img/NetBSD-amd64.iso
curl -L https://cdn.openbsd.org/pub/OpenBSD/6.3/amd64/install63.iso -o ./img/OpenBSD-amd64.iso
curl https://mirror.herrbischoff.com/dragonfly/iso-images/dfly-x86_64-5.2.1_REL.iso -o ./img/DragonFlyBSD-amd64.iso
