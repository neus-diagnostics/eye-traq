#!/bin/sh

# install and configure sshd as a Windows service
# source: https://gist.github.com/samhocevar/00eec26d9e9988d080ac

set -e

PRIV_USER=sshd_server
PRIV_NAME="Privileged user for sshd"
UNPRIV_USER=sshd # DO NOT CHANGE; this username is hardcoded in the openssh code
UNPRIV_NAME="Privilege separation user for sshd"

EMPTY_DIR=/var/empty

# install required packages
pacman -S -y --needed --noconfirm openssh cygrunsrv mingw-w64-x86_64-editrights

# shut up sshd warnings
touch /var/log/lastlog

# modify sshd_config: only ed25519 host key, disable password auth
sed -i /etc/ssh/sshd_config \
	-e 's@^#HostKey /etc/ssh/ssh_host_ed25519_key$@HostKey /etc/ssh/ssh_host_ed25519_key@' \
	-e 's@^#PasswordAuthentication yes$@PasswordAuthentication no@'

# generate host keys
ssh-keygen -A

# Some random password; this is only needed internally by cygrunsrv and
# is limited to 14 characters by Windows (lol)
tmp_pass="$(tr -dc 'a-zA-Z0-9' < /dev/urandom | dd count=14 bs=1 2>/dev/null)"

# create privilieged user
add="$(if ! net user "${PRIV_USER}" >/dev/null; then echo "//add"; fi)"
if ! net user "${PRIV_USER}" "${tmp_pass}" ${add} //fullname:"${PRIV_NAME}" \
              //homedir:"$(cygpath -w ${EMPTY_DIR})" //yes; then
    echo "ERROR: Unable to create Windows user ${PRIV_USER}"
    exit 1
fi

# add user to the Administrators group if necessary
admingroup="$(mkgroup -l | awk -F: '{if ($2 == "S-1-5-32-544") print $1;}')"
if ! (net localgroup "${admingroup}" | grep -q '^'"${PRIV_USER}"'$'); then
    if ! net localgroup "${admingroup}" "${PRIV_USER}" //add; then
        echo "ERROR: Unable to add user ${PRIV_USER} to group ${admingroup}"
        exit 1
    fi
fi

# set required privileges
for flag in SeAssignPrimaryTokenPrivilege SeCreateTokenPrivilege \
  SeTcbPrivilege SeDenyRemoteInteractiveLogonRight SeServiceLogonRight; do
    if ! /mingw64/bin/editrights -a "${flag}" -u "${PRIV_USER}"; then
        echo "ERROR: Unable to give ${flag} rights to user ${PRIV_USER}"
        exit 1
    fi
done

# unprivileged sshd user (for privilege separation)
add="$(if ! net user "${UNPRIV_USER}" >/dev/null; then echo "//add"; fi)"
if ! net user "${UNPRIV_USER}" ${add} //fullname:"${UNPRIV_NAME}" \
              //homedir:"$(cygpath -w ${EMPTY_DIR})" //active:no; then
    echo "ERROR: Unable to create Windows user ${PRIV_USER}"
    exit 1
fi

# register service with cygrunsrv and start it
cygrunsrv -R sshd || true
cygrunsrv -I sshd -d "MSYS2 sshd" -p \
          /usr/bin/sshd.exe -a "-D -e" -y tcpip -u "${PRIV_USER}" -w "${tmp_pass}"

# The SSH service should start automatically when Windows is rebooted. You can
# manually restart the service by running `net stop sshd` + `net start sshd`
if ! net start sshd; then
    echo "ERROR: Unable to start sshd service"
    exit 1
fi
