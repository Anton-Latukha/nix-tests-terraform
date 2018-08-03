#!/bin/sh
# This one creates Nix worker users and group because of https://github.com/NixOS/nix/issues/1559

groupadd -r nixbld
    for n in $(seq 1 10); do useradd -c "Nix build user $n" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(command -v nologin)" "nixbld$n"; done
