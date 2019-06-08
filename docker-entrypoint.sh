#!/bin/bash

# Add the fileshare group and user
groupadd --gid ${AFP_GID} ${AFP_USER}
adduser --uid ${AFP_UID} --gid ${AFP_GID} --no-create-home --disabled-password --gecos '' "${AFP_USER}"
# Store the secret in a Docker Secret and pass the secret name in as a variable
cat /run/secrets/netatalk_passwd | chpasswd

#Ensure that share directory exists and is owned by the fileshare user.
mkdir -p /media/share
chown "${AFP_USER}" /media/share

# Start dbus
mkdir -p /var/run/dbus
rm -f /var/run/dbus/pid
dbus-daemon --system

# Start avahi
sed -i '/rlimit-nproc/d' /etc/avahi/avahi-daemon.conf
avahi-daemon -D

exec netatalk -d
