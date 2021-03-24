# The magical world of Docker-Compose
I've known about this tool for a long time, however only invested time into learning and understanding it over the summer of 2020. In these notes are recipes, little how-to's, and general command and configuration reference.


## Compose files
We use `docker-compose.yml` or `.yaml` to specify how we want to deploy a series of docker containers. A simple such file to spawn instances of the `hello-world` image may be written
```
version "3.8"	# use the latest version

services:
	helloworld:
		image: hello-world
```
which we can then start with
```
docker-compose up
```
**NB:** if you have multiple configuration files, with different names, you can specific which compose file to use with the `-f` flag, such as
```
docker-compose -f test.yml [COMMAND]
```
For full documentation on writing compose files, see the [official docs](https://docs.docker.com/compose/compose-file/).

### Structuring a service
We can structure normal command line flags, such as for binding ports, volumes, or setting env variables, in the compose file as such
```
version: "3.8"
services:
	some_service:
		image: some/image:tag
		ports:
			- 80:8080
		expose:
			- 25655/udp
		volumes:
			- ~/www:/www
			- ${CONFIG_PATH}:/config
		environment:
			- ACCEPT_EULA=yes
		user: "${UID}:${GID}"
```
Lets examine a little bit what is going on here: we are using environment variables from the current `tty`, such as `UID` and `GID` to specify the permissions with which the container should run. **This can be crucial** when sharing volumes from the host machine, since it may require read/write permission, which by default it may not have.

We are also using `CONFIG_PATH` which can either be set in the `tty`, or configured in an environment variable file.

### Environment variables
Compose files read variables from `tty` and by default the `.env` file in the same directory as the compose file. This `.env` is formatted as key value pairs:
```
CONFIG_PATH=/path/to/config/
HTTP_PORT:80
...
```
More on environment variables and environment files can be found in the [official docs](https://docs.docker.com/compose/environment-variables/), and [syntax guide](https://docs.docker.com/compose/env-file/).

### Controlling startup and tear-down order
For more, see [the official docs](https://docs.docker.com/compose/startup-order/).

## Networks
Networks are replacing the legacy `link` statements in docker, as can be read in the [networking reference](https://docs.docker.com/compose/networking/).

## Volumes
TODO

## Configs (docker-swarm)
At the moment, this feature is [only available to docker swarm](https://docs.docker.com/engine/swarm/configs/), which I will explore and document later.

## Docker-Compose commands

### Scaling
You can spawn multiple instances of a service defined in your config file using
```
docker-compose up --scale some_service=5
```
This way, we spawn 5 containers of `some_service`.

## Discussions
In this section I want to elaborate on some thoughts I've had whilst using `docker-compose`.

### The importance of `down` 
When configuring e.g. complicated networks to run between your containers, you need to ensure they are properly taken down so that any changes you try to make, actually get implemented instead of throwing errors. Similarly, if you are tampering with services, by default sig-term in `docker-compose up` won't delete the previous containers, such that if you ran the command again, the containers would just be restarted, instead of new ones being created.

As we see in the [official docs](https://docs.docker.com/compose/reference/down/), the `down` command takes care of this for us by

- removing containers defined in the compose file
- removing networks defined in the compose file
- removing the default network if one was created

### Installing on \*nix
OSX has a simple installation with brew, however on e.g. Debian, the `apt` version only supports version 2 compose files. For a up-to-date install, use [this guide](https://docs.docker.com/compose/install/):
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
and enable execution
```
sudo chmod +x /usr/local/bin/docker-compose
```

## Example use cases
In this section are the compose file, and where relevant some explanation, for potential use cases:

### VerneMQ cluster
Consider trying to set up a VerneMQ cluster using this simple `docker-compose.yml`
```
version: "3.7"
services:
  verne_host:
    image: vernemq/vernemq
    environment:
      DOCKER_VERNEMQ_ACCEPT_EULA: "yes"
    networks:
      backend:
        ipv4_address: 172.18.5.2

  verne_slaves:
    image: vernemq/vernemq
    depends_on:
      - verne_host
    environment:
      DOCKER_VERNEMQ_DISCOVERY_NODE: "172.18.5.2"
      DOCKER_VERNEMQ_ACCEPT_EULA: "yes"
    networks:
      - backend

networks:
  backend:
    ipam:
      config:
        - subnet: 172.18.5.0/24
```

And start the scalable cluster with 
```bash
docker-compose up --scale verne_slaves=10
```

**NB:** I couldn't get host name resolves to work on the dockersized version of VerneMQ, hence the static IP assign. I have opened an issue in [`vernemq/docker-vernemq`](https://github.com/vernemq/docker-vernemq/issues/232).
