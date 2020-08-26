# Docker cheatsheet
Compiled from different projects.

<!--BEGIN TOC-->
## Table of Contents
1. [Command line](#toc-sub-tag-0)
	1. [Running images as containers](#toc-sub-tag-1)
	2. [Distributing docker containers](#toc-sub-tag-2)
	3. [Viewing container status](#toc-sub-tag-3)
	4. [Copying files](#toc-sub-tag-4)
	5. [Cleanup](#toc-sub-tag-5)
2. [Recipes](#toc-sub-tag-6)
	1. [Clustering](#toc-sub-tag-7)
	2. [Commiting Dockerfile Modifications](#toc-sub-tag-8)
<!--END TOC-->

## Command line <a name="toc-sub-tag-0"></a>
The docker CLI provides a wide range of methods for creating, maintaining, and removing both docker images and containers.

### Running images as containers <a name="toc-sub-tag-1"></a>
The `docker run` command offers many flags to change the behaviour of a docker container:

- `-d` : detach; run the container using the daemon (i.e. not in the current shell)
- `-p` : port; bind some `-p HOST:CONTAINER` port to the container
- `-v` : volume; share some directory `-v HOST:CONTAINER` with the container

You can pass environment variables using the `-e` flag, followed by a pair-value string
```
-e "MY_ENV_VAR=VALUE"
```

### Distributing docker containers <a name="toc-sub-tag-2"></a>
After a image has been built, it may be exported with
```bash
docker save -o [image-name].tar [image-name]
```
and loaded (e.g. on another machine)
```bash
docker load -i [image-name].tar
```

You can also commit a running container, and save the state of any modifications you have made into a new image with
```bash
docker commit [container-id/name]  new-image-name
```

All of the docker images can be listed with
```bash
docker image ls 
# or
docker images
```

### Viewing container status <a name="toc-sub-tag-3"></a>
A simple was of viewing the container status us to view the log files it produces (commonly just STDOUT in the container)
```bash
docker logs [container-id/name]
```
with an optional `-f` flag for following the output.

Another method is to attach to a running process if it is running in the background and/or started with the `-d` flag
```bash
docker attach [container-id/name]
```
NB: using `ctrl-C` or `ctrl-D` will kill the container much as if it were running in the current shell; use `ctrl-p` or `ctrl-q` instead.

You can spawn an interactive shell on a running container using
```bash
docker exec -it [container-id/name] /bin/bash
```

You can list the containers currently running with 
```bash
docker ps 
```
or all running and exited containers with 
```bash
docker ps -a
```

A JSON structure containing all information on a running container can be found with
```bash
docker inspect [container-id/name]
```

### Copying files <a name="toc-sub-tag-4"></a>
Files can be coied to and from running containers using
```bash
docker cp [local-path] [container-id/name]:[remote-path]
```

### Cleanup <a name="toc-sub-tag-5"></a>
Following instructions from [Hostinger](https://www.hostinger.com/tutorials/docker-remove-all-images-tutorial/), we can employ the following commands to clear unneeded containers, images, networks, and more:

```bash
docker image prune
```
removes recent, dangling and untagged images. This command will commonly have the `-a` flag to ensure all related files are deleted. You can also apply filters such as `--filter "until=24h"` to delete images created within a specific time frame.

To remove idle containers that have been stopped, use
```bash
docker container prune
```

For volumes and networks, the commands are likewise very similar
```bash
docker volume prune
docker network prune
```

To do all of these `prune` commands in one, execute
```bash
docker system prune
```

## Recipes <a name="toc-sub-tag-6"></a>
A few case studies in using different docker commands.

### Clustering <a name="toc-sub-tag-7"></a>
I recently set up a VerneMQTT cluster using docker images, which require knowledge of the IP addresses of the first host. This information can be found on a running container using the 
```bash
docker inspect [container-id/name] | jq ".[0].NetworkSettings.IPAddress"
```
command, which pipes the JSON structure into JQ, and extracts specifically just the IP address.


### Commiting Dockerfile Modifications <a name="toc-sub-tag-8"></a>
If you have a running container, but wish to modify it's behaviour so that port 80 is always exposed, you can do so [with the commit `--change` flag](https://docs.docker.com/engine/reference/commandline/commit/):
```bash
docker commit --change="EXPOSE 80" [container-id/name] new-image-name
# --change="" can also just be -c ""
```
