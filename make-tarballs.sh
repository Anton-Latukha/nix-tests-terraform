#!/bin/sh
case "$(uname -s).$(uname -m)" in
    Linux.x86_64) system='x86_64-linux'; hash='d6db178007014ed47ad5460c1bd5b2cb9403b1ec543a0d6507cb27e15358341f';;
    Linux.i?86) system='i686-linux'; hash='b2e5b62a66c6d1951fdd5e01109680592b498ef40f28bfc790341f5b986ba34d';;
    Linux.aarch64) system='aarch64-linux'; hash='248be69c25f599ac214bad1e4f4003e27f1da83cb17f7cd762746bd2c215a0df';;
    Darwin.x86_64) system='x86_64-darwin'; hash='ec6279bb6d628867d82a6e751dac2bcb64ccea3194d753756a309f75fd704d4c';;
    *) oops 'sorry, there is no binary distribution of Nix for your platform';;
esac

curl https://nixos.org/nix/install
