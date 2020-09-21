#!/bin/bash
set -e

function createUser {
    echo
    local VARIABLE_NAME=$1
    local C_USER="$VARIABLE_NAME"
    local C_USER_UID="${VARIABLE_NAME}_UID"
    local C_USER_GID="${VARIABLE_NAME}_GID"
    local C_USER_PASSWORD="${VARIABLE_NAME}_PASSWORD"
    local cmd
    echo "Creating user: " ${!VARIABLE_NAME}

    if [ ! -z "${!C_USER}" ]; then
        if [ ! -z "${!C_USER_UID}" ]; then
            cmd="$cmd --uid ${!C_USER_UID}"
        fi
        if [ ! -z "${!C_USER_GID}" ]; then
            cmd="$cmd --gid ${!C_USER_GID}"
            groupadd --gid ${!C_USER_GID} "${!C_USER}"
        fi
        adduser $cmd --no-create-home --disabled-password --gecos '' "${!C_USER}"
        usermod -a -G netatalk-files "${!C_USER}"
        if [ ! -z "${!C_USER_PASSWORD}" ]; then
            echo "${!C_USER}:${!C_USER_PASSWORD}" | chpasswd
        fi
    fi
    echo
}

if [ ! -e ".NotFirstRun" ]; then
    groupadd --gid 9934 netatalk-files

    while IFS='=' read -r name value ; do
        if [[ $name =~ ^AFP_USER_[0-9]+$ ]] || [[ $name =~ ^AFP_USER$ ]] ; then
            createUser $name
        fi
    done < <(env|sort -h)
    touch .NotFirstRun
fi

if [ ! -d /media/share ]; then
  mkdir -p /media/share
  echo "use -v /my/dir/to/share:/media/share" > readme.txt
fi
chgrp netatalk-files /media/share
chmod g+rwx /media/share

if [ ! -d /media/timemachine ]; then
  mkdir -p /media/timemachine
  echo "use -v /my/dir/to/timemachine:/media/timemachine" > readme.txt
fi

chgrp netatalk-files /media/timemachine
chmod g+rwx /media/timemachine

if [ -f /etc/afp.conf ]; then
	cp /etc/afp.conf /tmp/afp.conf
	sed -i'' -e "s,%AFP_NAME%,${AFP_NAME:-},g" /tmp/afp.conf
	sed -i'' -e "s,%AFP_SPOTLIGHT%,${AFP_SPOTLIGHT:-},g" /tmp/afp.conf
	sed -i'' -e "s,%AFP_ZEROCONF%,${AFP_ZEROCONF:-},g" /tmp/afp.conf
	cat /tmp/afp.conf > /etc/netatalk/afp.conf
else
	sed -i'' -e "s,%AFP_NAME%,${AFP_NAME:-},g" /etc/netatalk/afp.conf
        sed -i'' -e "s,%AFP_SPOTLIGHT%,${AFP_SPOTLIGHT:-},g" /etc/netatalk/afp.conf
        sed -i'' -e "s,%AFP_ZEROCONF%,${AFP_ZEROCONF:-},g" /etc/netatalk/afp.conf
fi

# Start dbus
mkdir -p /var/run/dbus
rm -f /var/run/dbus/pid
dbus-daemon --system

# Start avahi
sed -i '/rlimit-nproc/d' /etc/avahi/avahi-daemon.conf
avahi-daemon -D

exec netatalk -d
