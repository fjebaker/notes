# Docker cheatsheet
Compiled from different projects.

## Command line
The docker CLI provides a wide range of methods for creating, maintaining, and removing both docker images and containers.

### Running images as containers
The `docker run` command offers many flags to change the behaviour of a docker container:

- `-d` : detach; run the container using the daemon (i.e. not in the current shell)
- `-p` : port; bind some `-p HOST:CONTAINER` port to the container
- `-v` : volume; share some directory `-v HOST:CONTAINER` with the container

### Distributing docker containers
After a image has been built, it may be exported with
```bash
docker save -o [image-name].tar [image-name]
```
and loaded (e.g. on another machine)
```bash
docker load -i [image-name].tar
```

### Viewing container status
A simple was of viewing the container status us to view the log files it produces (commonly just STDOUT in the container)
```bash
docker logs [container-id]
```
with an optional `-f` flag for following the output.

Another method is to attach to a running process if it is running in the background and/or started with the `-d` flag
```bash
docker attach [container-id]
```
NB: using `ctrl-C` or `ctrl-D` will kill the container much as if it were running in the current shell; use `ctrl-p` or `ctrl-q` instead.

## Docker files