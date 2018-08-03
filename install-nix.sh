#!/bin/sh

# This script runs presetup. Then basing on system and arch - runs apropriate installation.
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

readonly self="$(dirname "$(realpath "$0")")"
readonly appname="$0"

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

"$self"/hack.sh

NIX_ONELINER_SOURCE_URL="$(grep -e '^url=' "$self"/one-liner.sh | sed 's/^url=//g' | tr -d '"') || error 'one-liner.sh could not be parsed'"

# From one-liner 'url' variable determine Nix version, yes - it is hardcoded there in 'url' variable.
NIX_VER="$(printf "%s" "$NIX_ONELINER_SOURCE_URL" | sed 's>^https://nixos.org/releases/nix/>>g' | cut -d'/' -f1)"

rm "$self"/one-liner.sh

# Let's hardcode the archs and OSes Nix supports
NIX_DARWIN_64='x86_64-darwin'
NIX_UNIX_64='x86_64-linux'
NIX_UNIX_32='i686-linux'
NIX_UNIX_ARM='aarch64-linux'

case "$(uname -s).$(uname -m)" in
    Darwin.x86_64) exec "$self/$NIX_VER-$NIX_DARWIN_64"/install-new ;;
    *.x86_64) exec "$self/$NIX_VER-$NIX_UNIX_64"/install-new ;;
    *.i?86) exec "$self/$NIX_VER-$NIX_UNIX_32"/install-new ;;
    *.aarch64) "$self/$NIX_VER-$NIX_UNIX_ARM"/install-new ;;
    *) oops "sorry, there is no binary distribution of Nix for your platform";;
esac

