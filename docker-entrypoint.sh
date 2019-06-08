#!/bin/bash
set -e

function createUser {
    echo
    local VARIABLE_NAME=$1
    local C_USER="$VARIABLE_NAME"
    local C_USER_UID="${VARIABLE_NAME}_UID"
    local C_USER_PASSWORD="${VARIABLE_NAME}_PASSWORD"
    local cmd
    echo "Creating user: " ${!VARIABLE_NAME}

    if [ ! -z "${!C_USER}" ]; then
        if [ ! -z "${!C_USER_UID}" ]; then
            cmd="$cmd --uid ${!C_USER_UID}"
        fi
        if [ ! -z "${AFP_GID}" ]; then
            cmd="$cmd --gid ${AFP_GID}"
            groupadd --gid ${AFP_GID} netatalk-files 2>&1 > /dev/null || true
        fi
        adduser $cmd --no-create-home --disabled-password --gecos '' "${!C_USER}"
        if [ ! -z "${!C_USER_PASSWORD}" ]; then
            echo "${!C_USER}:${!C_USER_PASSWORD}" | chpasswd
        fi
    fi
    echo
}

USERS=""

while IFS='=' read -r name value ; do
    if [[ $name =~ ^AFP_USER_[0-9]+$ ]] || [[ $name =~ ^AFP_USER$ ]] ; then
        createUser $name
        USERS="$USERS, ${!name}"
    fi
done < <(env|sort -h)


if [ ! -d /media/share ]; then
  mkdir -p /media/share
  echo "use -v /my/dir/to/share:/media/share" > readme.txt
fi
chown "${AFP_GID}" /media/share

if [ ! -d /media/timemachine ]; then
  mkdir -p /media/timemachine
  echo "use -v /my/dir/to/timemachine:/media/timemachine" > readme.txt
fi
chown "${AFP_GID}" /media/timemachine

sed -i'' -e "s|%USERS%|${USERS:-}|g" /etc/netatalk/afp.conf
sed -i'' -e "s,%AFP_NAME%,${AFP_NAME:-},g" /etc/netatalk/afp.conf
sed -i'' -e "s,%AFP_SPOTLIGHT%,${AFP_SPOTLIGHT:-},g" /etc/netatalk/afp.conf
sed -i'' -e "s,%AFP_ZEROCONF%,${AFP_ZEROCONF:-},g" /etc/netatalk/afp.conf

# Start dbus
mkdir -p /var/run/dbus
rm -f /var/run/dbus/pid
dbus-daemon --system

# Start avahi
sed -i '/rlimit-nproc/d' /etc/avahi/avahi-daemon.conf
avahi-daemon -D

exec netatalk -d
