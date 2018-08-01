#!/bin/sh
# This script is solely to get the official one-liner, and tarballs
# and get info from them,
# and apply new POSIX installation to them, for testing purposes.

# This is script to automate and support pull request testing,
# it is convenience frankenstine script, do not look for quality here.

###############################
###  Setup environment
###############################
{
# Set the character collating sequence to be numeric ASCII/C standard.
# Set the character set to be standard one-byte ASCII.
# Set default umask; to be non-restrictive and friendly to others.
#
readonly LC_COLLATE=C
readonly LANG=C
umask 022
}


###############################
###  Main constants
###############################
{
readonly dest='/nix'
readonly self="$(dirname "$(realpath "$0")")"
readonly nix="@nix@"
readonly cacert="@cacert@"
readonly appname="$0"
}


###############################
###  CLI control constants
###############################
{
# If file descriptor is associated with a terminal - output colors
if test -t ; then
    # If terminal reports a terminfo/termcap DB of colors available - use DB.
    # Else - use literal color codes.
    if tput colors > /dev/null 2>&1 ; then
        # use tput and terminfo DB
        readonly red=$(tput setaf 1)
        readonly green=$(tput setaf 2)
        readonly yellow=$(tput setaf 3)
        readonly blue=$(tput setaf 4)
        readonly bold=$(tput smso)
        readonly reset=$(tput sgr0) # Reset to default output
    else
        # tput is not present on some systems (Alpine Linux),
        # this trick with printf allows to store, not 'codes' - literal symbols
        readonly red=$(printf '\033[1;31m')
        readonly green=$(printf '\033[1;32m')
        readonly yellow=$(printf '\033[1;33m')
        readonly blue=$(printf '\033[1;34m')
        readonly bold=$(printf '\033[1m')
        readonly reset=$(printf '\033[0;m') # Reset to default output
    fi
fi
}


###############################
###  CLI output functions
###############################
{
# Unified output function
print() {
    # Using `printf`, because it is more portable than `echo`.
    #
    if [ -z "$message" ]; then
        message="$1"
    fi
    if [ -z "$color" ]; then
        color="$reset"
    fi
    if [ -z "$prefix" ]; then
        prefix='Info'
    fi
    # This line makes all prints in script
    # Form of message:
    # Application: Prefix: Body of message
    printf '%s%s: %s: %s%s\n' "$color" "$appname" "$prefix" "$message" "$reset"

    # Output is done, unset variables that could've been set by parent functions
    unset color
    unset prefix
    unset message
}

notice() {
    message="$1"
    color="$green"
    prefix='Notice'
    print
}

warning() {
    message="$1"
    color="$yellow"
    prefix='Warning'
    >&2 print
}

error() {
    message="$1"
    exitSig="$2"
    color="$red"
    prefix='Error'
    >&2 print
    if [ -z "$exitSig" ]; then
        exit 1
    fi
}

errorRevert() {
    message="$1"
    color="$red"
    prefix='Error'
    >&2 print
}

contactUs() {
    print '

    To search/open bugreports: https://github.com/nixos/nix/issues

    To contact the team and community:
     - IRC: #nixos on irc.freenode.net
     - Twitter: @nixos_org

    Matrix community rooms: https://matrix.to/#/@nix:matrix.org
                            https://matrix.to/#/@nixos:matrix.org
'
}

}


oops() {
    echo "$0:" "$@" >&2
    exit 1
}

cleanup() {
    rm -rf "$tmpDir"
}

curl https://nixos.org/nix/install

url="https://nixos.org/releases/nix/nix-2.0.4/nix-2.0.4-$system.tar.bz2"

tarball="$tmpDir/$(basename "$tmpDir/nix-2.0.4-$system.tar.bz2")"
echo "downloading Nix 2.0.4 binary tarball for $system from '$url' to '$tmpDir'..."
curl -L "$url" -o "$tarball" || oops "failed to download '$url'"


case "$(uname -s).$(uname -m)" in
    Darwin.x86_64) system='x86_64-darwin'; hash='ec6279bb6d628867d82a6e751dac2bcb64ccea3194d753756a309f75fd704d4c';;
    *.x86_64) system='x86_64-linux'; hash='d6db178007014ed47ad5460c1bd5b2cb9403b1ec543a0d6507cb27e15358341f';;
    *.i?86) system='i686-linux'; hash='b2e5b62a66c6d1951fdd5e01109680592b498ef40f28bfc790341f5b986ba34d';;
    *.aarch64) system='aarch64-linux'; hash='248be69c25f599ac214bad1e4f4003e27f1da83cb17f7cd762746bd2c215a0df';;
esac

NIX_VER='nix-2.0.2'

NIX_SYSTEM='x86_64-linux'
NIX_EXT='tar.bz2'
NIX_URL="https://nixos.org/releases/nix/$NIX_VER/$NIX_VER-$NIX_SYSTEM.$NIX_EXT"

mkdir ~/build
cd ~/build

# Clone current updated installation process
git clone -b installFullProgress https://github.com/Anton-Latukha/nix.git installFullProgress

# Download and extract official installation
curl -L "$NIX_URL" -O
tar xvf "$NIX_VER"-"$NIX_SYSTEM"."$NIX_EXT"
rm "$NIX_VER"-"$NIX_SYSTEM"."$NIX_EXT"

# Copy updated instalation to nix install folder
cp ./installFullProgress/scripts/install-nix-from-closure.sh ./"$NIX_VER"-"$NIX_SYSTEM"/install-new
chmod u+x ./"$NIX_VER"-"$NIX_SYSTEM"/install-new

cd "/root/build/$NIX_VER-$NIX_SYSTEM"

# Apply patch that populates build variables with relevant ones
## This is a patch
echo '\
--- install-nix-from-closure.sh	2017-10-28 14:04:24.812532357 +0200\n\
+++ install-nix-from-closure-new.sh	2017-10-28 14:03:49.104006041 +0200\n\
@@ -89,8 +89,8 @@\n\
 {\n\
 readonly dest="/nix"\n\
 readonly self="$(dirname "$(realpath "$0")")"\n\
-readonly nix="@nix@"\n\
-readonly cacert="@cacert@"\n\
+readonly nix="/nix/store/b4s1gxiis1ryvybnjhdjvgc5sr1nq0ys-nix-1.11.15"\n\
+readonly cacert="/nix/store/28v6ma4zb887m7ldrbqh56r8jjxc53cb-nss-cacert-3.31"\n\
 readonly appname="$0"\n\
 }\n\
 ###############################\n\
' >> git_to_deploy.patch
## Applying
patch install-new.sh git_to_deploy.patch

# Banner
echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd' \
    >> /etc/bash.bashrc \
    ; echo '\033[1;32m\
======================================================================\n\
= Docker container for new Nix install demonstration for NixCon 2017 =\n\
======================================================================\n\
\n\
Installation solves bugs of installator. It is tranparent to migrate to.\n\
\n\
Because it stays transparent to migrate upstream to - it also uses single\n\
user Nix installation, as old does.\n\
\n\
And so it falls on nixbld group, because single user installation does\n\
not requires nix workers by official documentation.\n\
\n\
Providing nixbld group and workers is a pure WND of expectations of Nix C++ code.\n\
So it needs to be upplied manually:\n\
\033[1;33m \n\
######## Multiuser block: \n\
groupadd -r nixbld\n\
for n in $(seq 1 10); do useradd -c "Nix build user $n" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(which nologin)" "nixbld$n"; done\n\
\033[0;m\
########\n\
\n\
(c) Anton Latukha, Serokell 2017 \n\
\n\
Source directory: '"$PWD"'\n'\
> /etc/motd
