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

cleanup() {
    rm -rf "$NIX_TMPDIR"
}


NIX_TMPDIR="$(mktemp -d -t nix-binary-tarball-unpack.XXXXXXXXXX)"

cd "$NIX_TMPDIR" || error "Can not open $NIX_TMPDIR"

curl -L https://nixos.org/nix/install -o one-liner.sh || error 'Couuld not download&save one-liner'

NIX_ONELINER_SOURCE_URL="$(grep -e '^url=' ./one-liner.sh | sed 's/^url=//g' | tr -d '"') || error 'one-liner.sh could not be parsed'"

# From one-liner 'url' variable determine Nix version, yes - it is hardcoded there in 'url' variable.
NIX_VER="$(printf "%s" "$NIX_ONELINER_SOURCE_URL" | sed 's>^https://nixos.org/releases/nix/>>g' | cut -d'/' -f1)"

# Let's store and then process information from the Nix case block
NIX_ONELINER_CASE_BLOCK="$(sed -n -e '/case "$(uname -s).$(uname -m)" in/,/esac/ p' ./one-liner.sh | grep -v '^case' | grep -v '^esac' | grep -v '^.*) oops'  | tr -d ';')"

# Let's hardcode the archs and OSes Nix supports
NIX_DARWIN_64='x86_64-darwin'
NIX_UNIX_64='x86_64-linux'
NIX_UNIX_32='i686-linux'
NIX_UNIX_ARM='aarch64-linux'

# Let's gather hashes for archs
NIX_TARBALL_HASH_DARWIN_64="$(printf "%s" "$NIX_ONELINER_CASE_BLOCK" | grep 'Darwin.x86_64' | cut -d'=' -f3)"
NIX_TARBALL_HASH_UNIX_64="$(printf "%s" "$NIX_ONELINER_CASE_BLOCK"   | grep 'Linux.x86_64'  | cut -d'=' -f3)"
NIX_TARBALL_HASH_UNIX_32="$(printf "%s" "$NIX_ONELINER_CASE_BLOCK"   | grep 'Linux.i?86'    | cut -d'=' -f3)"
NIX_TARBALL_HASH_UNIX_ARM="$(printf "%s" "$NIX_ONELINER_CASE_BLOCK"  | grep 'Linux.aarch64' | cut -d'=' -f3)"

NIX_EXT='tar.bz2'
NIX_DARWIN_64_TARBALL_FILENAME="$NIX_VER-$NIX_DARWIN_64.$NIX_EXT"
NIX_UNIX_64_TARBALL_FILENAME="$NIX_VER-$NIX_UNIX_64.$NIX_EXT"
NIX_UNIX_32_TARBALL_FILENAME="$NIX_VER-$NIX_UNIX_32.$NIX_EXT"
NIX_UNIX_ARM_TARBALL_FILENAME="$NIX_VER-$NIX_UNIX_ARM.$NIX_EXT"

NIX_DARWIN_64_URL="https://nixos.org/releases/nix/$NIX_VER/$NIX_DARWIN_64_TARBALL_FILENAME"
NIX_UNIX_64_URL="https://nixos.org/releases/nix/$NIX_VER/$NIX_UNIX_64_TARBALL_FILENAME"
NIX_UNIX_32_URL="https://nixos.org/releases/nix/$NIX_VER/$NIX_UNIX_32_TARBALL_FILENAME"
NIX_UNIX_ARM_URL="https://nixos.org/releases/nix/$NIX_VER/$NIX_UNIX_ARM_TARBALL_FILENAME"

NIX_DARWIN_64_TARBALL_PATH="$NIX_TMPDIR/$NIX_DARWIN_64_TARBALL_FILENAME"
NIX_UNIX_64_TARBALL_PATH="$NIX_TMPDIR/$NIX_UNIX_64_TARBALL_FILENAME"
NIX_UNIX_32_TARBALL_PATH="$NIX_TMPDIR/$NIX_UNIX_32_TARBALL_FILENAME"
NIX_UNIX_ARM_TARBALL_PATH="$NIX_TMPDIR/$NIX_UNIX_ARM_TARBALL_FILENAME"

# Now let's download tarblalls

notice "Downloading $NIX_VER binary tarball for $NIX_DARWIN_64 from '$NIX_DARWIN_64_URL' to 'NIX_TMPDIR'..."
curl -L "$NIX_DARWIN_64_URL" -o "$NIX_DARWIN_64_TARBALL_PATH" || error "failed to download '$NIX_URL' into '$NIX_DARWIN_64_TARBALL_PATH'"

notice "Downloading $NIX_VER binary tarball for $NIX_UNIX_64 from '$NIX_UNIX_64_URL' to 'NIX_TMPDIR'..."
curl -L "$NIX_UNIX_64_URL" -o "$NIX_UNIX_64_TARBALL_PATH" || error "failed to download '$NIX_URL' into '$NIX_UNIX_64_TARBALL_PATH'"

notice "Downloading $NIX_VER binary tarball for $NIX_UNIX_32 from '$NIX_UNIX_32_URL' to 'NIX_TMPDIR'..."
curl -L "$NIX_UNIX_32_URL" -o "$NIX_UNIX_32_TARBALL_PATH" || error "failed to download '$NIX_URL' into '$NIX_UNIX_32_TARBALL_PATH'"

notice "Downloading $NIX_VER binary tarball for $NIX_UNIX_ARM from '$NIX_UNIX_ARM_URL' to 'NIX_TMPDIR'..."
curl -L "$NIX_UNIX_ARM_URL" -o "$NIX_UNIX_ARM_TARBALL_PATH" || error "failed to download '$NIX_URL' into '$NIX_UNIX_ARM_TARBALL_PATH'"

# Download and extract official installation
tar xvf "$NIX_DARWIN_64_TARBALL_FILENAME"
rm "$NIX_DARWIN_64_TARBALL_FILENAME"

tar xvf "$NIX_UNIX_64_TARBALL_FILENAME"
rm "$NIX_UNIX_64_TARBALL_FILENAME"

tar xvf "$NIX_UNIX_32_TARBALL_FILENAME"
rm "$NIX_UNIX_32_TARBALL_FILENAME"

tar xvf "$NIX_UNIX_ARM_TARBALL_FILENAME"
rm "$NIX_UNIX_ARM_TARBALL_FILENAME"

# Clone updated installation
git clone -b installFullProgress https://github.com/Anton-Latukha/nix.git installFullProgress

# Copy updated instalation to nix install folder
cp ./installFullProgress/scripts/install-nix-from-closure.sh ./"$NIX_VER-$NIX_DARWIN_64"/install-new
chmod u+x "$NIX_TMPDIR/$NIX_VER-$NIX_DARWIN_64"/install-new

cp ./installFullProgress/scripts/install-nix-from-closure.sh ./"$NIX_VER-$NIX_UNIX_64"/install-new
chmod u+x "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_64"/install-new

cp ./installFullProgress/scripts/install-nix-from-closure.sh ./"$NIX_VER-$NIX_UNIX_32"/install-new
chmod u+x "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_32"/install-new

cp ./installFullProgress/scripts/install-nix-from-closure.sh ./"$NIX_VER-$NIX_UNIX_ARM"/install-new
chmod u+x "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_ARM"/install-new

NIX_DARWIN_64_VAR="$(grep '^nix=' "$NIX_TMPDIR/$NIX_VER-$NIX_DARWIN_64"/install | sed 's/^nix=//g' | tr -d '"')"
NIX_UNIX_64_VAR="$(grep '^nix=' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_64"/install | sed 's/^nix=//g' | tr -d '"')"
NIX_UNIX_32_VAR="$(grep '^nix=' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_32"/install | sed 's/^nix=//g' | tr -d '"')"
NIX_UNIX_ARM_VAR="$(grep '^nix=' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_ARM"/install | sed 's/^nix=//g' | tr -d '"')"

NIX_DARWIN_64_CERT="$(grep '^cacert=' "$NIX_TMPDIR/$NIX_VER-$NIX_DARWIN_64"/install | sed 's/^cacert=//g' | tr -d '"')"
NIX_UNIX_64_CERT="$(grep '^cacert=' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_64"/install | sed 's/^cacert=//g' | tr -d '"')"
NIX_UNIX_32_CERT="$(grep '^cacert=' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_32"/install | sed 's/^cacert=//g' | tr -d '"')"
NIX_UNIX_ARM_CERT="$(grep '^cacert=' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_ARM"/install | sed 's/^cacert=//g' | tr -d '"')"

sed 's|^readonly nix=\".*\"|readonly nix='"$NIX_DARWIN_64_VAR"'|g' "$NIX_TMPDIR/$NIX_VER-$NIX_DARWIN_64"/install-new
sed 's|^readonly nix=\".*\"|readonly nix='"$NIX_UNIX_64_VAR"'|g' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_64"/install-new
sed 's|^readonly nix=\".*\"|readonly nix='"$NIX_UNIX_32_VAR"'|g' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_32"/install-new
sed 's|^readonly nix=\".*\"|readonly nix='"$NIX_UNIX_ARM_VAR"'|g' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_ARM"/install-new

sed 's|^readonly cacert=\".*\"|readonly cacert='"$NIX_DARWIN_64_CERT"'|g' "$NIX_TMPDIR/$NIX_VER-$NIX_DARWIN_64"/install-new
sed 's|^readonly cacert=\".*\"|readonly cacert='"$NIX_UNIX_64_CERT"'|g' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_64"/install-new
sed 's|^readonly cacert=\".*\"|readonly cacert='"$NIX_UNIX_32_CERT"'|g' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_32"/install-new
sed 's|^readonly cacert=\".*\"|readonly cacert='"$NIX_UNIX_ARM_CERT"'|g' "$NIX_TMPDIR/$NIX_VER-$NIX_UNIX_ARM"/install-new

cd "./$NIX_VER-$NIX_SYSTEM" || error "Can not go into $(pwd)/$NIX_VER-$NIX_SYSTEM"

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

