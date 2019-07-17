#!/bin/sh

# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright © 2018 Neus Diagnostics, d.o.o.

# install Tor and configure a hidden service for SSH
set -e

if [ $# -ne 1 ] ; then
    echo "usage: ${0} tor-win32-*.zip"
    exit 1
fi

bundle="${1}"

# install required packages
pacman -S -y --needed --noconfirm unzip

unzip -o -d '/c/tor' "${bundle}"
cat > '/c/tor/torrc' <<EOF
HiddenServiceDir c:\tor\Data\ssh
HiddenServicePort 22 127.0.0.1:22
HiddenServiceVersion 3
EOF

/c/tor/Tor/tor.exe --service install -options -f 'C:\\tor\\torrc' || true

echo 'Hidden service address:'
cat /c/tor/Data/ssh/hostname
