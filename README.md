This repo is a fork of this excellent repo https://github.com/cptactionhank/docker-netatalk to compile netatalk to run on a Docker swarm of raspberry pis.

## Changelog

1. Updated netalk version to 3.1.12
1. Changed Debian version from Jessie to Stretch-slim
1. Updated afp.conf to remove anonymous access
1. Remove avahi ENV var (always run)