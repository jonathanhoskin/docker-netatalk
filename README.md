This repo is a fork of this excellent repo https://github.com/cptactionhank/docker-netatalk to updating and improving the base implementation.

## Changelog from original repo


1. Changed Debian version from Jessie to Buster-slim
2. Install netatalk from official Debian repository
3. Added `dokcer-compose.yml` for ease of use
4. Option to create multiple users
5. Updated afp.conf to remove anonymous access
6. Remove avahi ENV var (always run)

