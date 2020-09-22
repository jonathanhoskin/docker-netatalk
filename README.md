
### Alert ###
I have reforked this from https://github.com/vchavkov and added some tweaks for using your own afp.conf file.

-Dave

## Alert ##

This repo is a fork of this excellent repo https://github.com/cptactionhank/docker-netatalk to updating and improving the base implementation.

### Changelog from original repo


1. Changed Debian version from Jessie to Buster-slim
1. Install netatalk from official Debian repository
1. Added `docker-compose.yml` for ease of use
1. Option to create multiple users
1. Updated afp.conf to remove anonymous access
1. Remove avahi ENV var (always run)
1. Other configurations by env vars
1. Fixed ability to use custom afp.conf files passed through to /etc/afp.conf

#### I'm in the fast lane! Get me started

To quickly get started with running an [Netatalk] container first you can run the following command:

```bash
docker run \
    --detach \
    --publish 548:548 \
    dfiore/netatalk
```

**Important:** This does not announce the AFP service on the network; connecting to the server should be performed by Finder's `Go -> Connect Server (CMD+K)` and then typing `afp://[docker_host]`.

Default configuration of [Netatalk] has two share called _Share_ which shares the containers `/media/share` and called _TimeMachine_ which shares the containers `/media/timemachine` mounting point. Host mounting a volume to this path will be the quickest way to start sharing files on your network.

```bash
docker run \
    --detach \
    --volume [host_path]:/media/share \
    --volume [host_path]:/media/timemachine \
    --publish 548:548 \
    dfiore/netatalk
```

Alternatively, it can be executed using docker-compose with the following command:

```bash
docker-compose up -d
```

#### The slower road

With the slower roads documentation some knowledge in administering Docker and [Netatalk] assumed.

##### Configuring shares

There are two ways of configuring the [Netatalk] which is either by mounting a configuration file or editing the file from the container itself. Documentation of the configuration file `/etc/afp.conf` can be found [here](http://netatalk.sourceforge.net/3.1/htmldocs/afp.conf.5.html).

###### Host mounted configuration

This is quite a simple way to change the configuration by supplying an additional docker flag when creating the container. ** Note: please use the example afp.conf hosted here if you are intending to use the environmental variables highlighted below. **

```bash
docker run \
    --detach \
    --volume [host_path]:/etc/afp.conf \
    --volume [host_path]:/media/share \
    --volume [host_path]:/media/timemachine \
    --publish 548:548 \
    dfiore/netatalk
```

##### Setting up with environment variables

That variables could be setted in a file called `netatalk.env`. This file is used by the [docker-compose.yml](./docker-compose.yml) file or by using the flag `--env-file` when exec the `docker run` command.

###### Configuration

|Variable       |Description|
|---------------|-----------|
|AFP_SPOTLIGHT  | (yes/**no**) Enables the possibility that, when searching in spotlight on the mac, shows results of these volumes |
|AFP_ZEROCONF   | (yes/**no**) Enables the possibility that it can be detected on local networks. This must be complemented using `host` network when executing the container |
|AFP_NAME       | (def: **Netatalk-server**) Name of the device to be displayed |

###### Access credentials

To setup access credentials you should supply the following environment variables from the table below.

|Variable          |Description|
|------------------|-----------|
|AFP_USER          | create a user in the container and allow it access to /media/share |
|AFP_USER_PASSWORD | password
|AFP_USER_UID      | (optional) _uid_ of the created user
|AFP_USER_GID      | (optional) _gid_ of the created user

If you need to **add more user** you can do it adding the user number. For example, `AFP_USER_2`, `AFP_USER_2_PASSWORD` or `AFP_USER_15`.


##### Service discovery

This image includes an avahi daemon which makes it discoverable on the network. Enable by setting the environment variable `AFP_ZEROCONF=true`.

Service discovery works only when the container use the same network as the users which is why you need to run the container in `host` network, but do consider that it is considered a security threat. That option could be enable be supply `--net=host` flag to Docker or by enabling `docker-compose.override-net.yml` with the command:

```bash
ln -s docker-compose.override-net.yml docker-compose.override.yml
```

Alternatively you can install and setup an mDNS server on the host and have this describing the AFP service for your container.

#### Acknowledgments

Thanks to @rrva for his work updating this image to [Netatalk] version 3.1.8 and slimming down this image for everyone to enjoy.

#### Contributions

This image has been created with the best intentions and an expert understanding of docker, but it should not be expected to be flawless. Should you be in the position to do so, I request that you help support this repository with best-practices and other additions.

If you see out of date documentation, lack of tests, etc., you can help out by either
- creating an issue and opening a discussion, or
- sending a pull request with modifications

This work is made possible with the great services from [Docker] and [GitHub].

[Netatalk]: http://netatalk.sourceforge.net/
[Docker]: https://www.docker.com/
[GitHub]: https://www.github.com/
[Avahi]: http://www.avahi.org/
