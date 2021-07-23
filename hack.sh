#!/bin/sh
# This one creates Nix worker users and group because of https://github.com/NixOS/nix/issues/1559

groupadd -r nixbld
    for n in $(seq 1 10); do useradd -c "Nix build user $n" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(command -v nologin)" "nixbld$n"; done

if ! getent group nixbld ; then
    addgroup -g 30000 -S nixbld

    for i in $(seq -w 1 30); do
        adduser -S -D -h /var/empty -g "Nix build user $i" -u 300"$i" -G nixbld "nixbld$i"
    done
fi
