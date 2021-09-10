# Creating a persistent local registry with S3/MinIO

The network design is
- MinIO running on a separate host (replicating AWS s3)
- docker registry hosted as a service through docker swarm

<!--BEGIN TOC-->
## Table of Contents
1. [Configurations](#configurations)
2. [Starting the registry service](#starting-the-registry-service)

<!--END TOC-->

## Configurations

We will use [Docker Configs](https://docs.docker.com/engine/swarm/configs/) as a convenient way of handling configuration files over the raft architecture of swarm.

The registry configuration documentation can be found [here](https://docs.docker.com/registry/configuration/). A possibly configuration for our aim could be:
```yml
# registry-config.yml
version: 0.1
log:
  fields:
    service: registry
    environment: staging

storage:
  # allow in-memory caching
  cache:
    blobdescriptor: inmemory
  s3:
    accesskey: [accessKey]
    secretkey: [secretAccessKey]
    region: eu-west-1
    regionendpoint: http://[endpoint]:9000
    bucket: docker
    encrypt: false

    # no https
    secure: false
    skipverify: true

    # upload 5 MB chunks (minimum size)
    chunksize: 5242880

    # directory of bucket to use
    rootdirectory: /
  delete:
    enabled: true

http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
```
Where we have configured an S3 type storage for the docker registry repositories.

For the S3 configuration reference, see [the storage driver docs](https://github.com/docker/docker.github.io/blob/master/registry/storage-drivers/s3.md).

We then create a Docker Config with
```bash
docker config create registry /path/to/registry-config.yml
```
As far as I can tell, to update the configuration, you have to remove the config
```bash
docker config rm registry
```
and then create it again with the updated file. There doesn't seem to be an update command, like with managing services, despite configs only being usable for services.

## Starting the registry service

As documented in [another of my notes on Docker Swarm](https://github.com/febk/dust-notes/blob/master/docker/docker-swarm.md), we can deploy a registry service with
```bash
docker service create -p 5000:5000 -d \
  --name registry \
  registry:2
```
however to register our configuration file, we need to use a syntax provided in the [docker examples](https://docs.docker.com/engine/swarm/configs/#example-use-a-templated-config), and modify our service with
```bash
docker service create -p 5000:5000 -d \
  --name registry \
  --config src=registry,target="/etc/docker/registry/config.yml" \
  registry:2
```

Inspect the logs with
```bash
docker service logs registry
```
to make sure everything is healthy. We can then push an image to our local registry
```bash
docker push [endpoint]:5000/some-image
```
check that it uploaded successfully with
```bash
curl [endpoint]:5000/v2/_catalog
```
and view it in our storage bucket under `/docker`.
