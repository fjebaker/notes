# Dockerfile cookbook
Different idioms and recipes for writing dockerfiles.

<!--BEGIN TOC-->
## Table of Contents
1. [Using throwaway containers](#toc-sub-tag-0)
2. [Running multiple processes in a single container](#toc-sub-tag-1)
3. [Discussions](#toc-sub-tag-2)
	1. [`ENTRYPOINT` vs `CMD`](#toc-sub-tag-3)
	2. [Good practices](#toc-sub-tag-4)
<!--END TOC-->

## Using throwaway containers <a name="toc-sub-tag-0"></a>
Consider having a Vue website, which you want to serve with a flask backend. Creating a container with both Vue and Flask executables would be highly bloated: instead, we can use throwaway containers to build different aspects of our project, and copy them into the final container:

```Dockerfile
FROM node:current-alpine3.11 AS installer

# fetch or copy in the source code for javascript

RUN npm i . && npm run build


FROM python:3.8.5-slim-buster
COPY --from=installer /dist /web

RUN pip install -r requirements.txt

CMD ["flask", "run", "-h", "0.0.0.0", "-p", "8080"]

EXPOSE 8080
```

Here, the `node:current-alpine3.11` container is aliased `installer` and is not bundled into our final `python:3.8.5-slim-buster` container, reducing the final size, and not shipping unneeded executables.

## Running multiple processes in a single container <a name="toc-sub-tag-1"></a>
This follows from a suggestion in the [docker documentation](https://docs.docker.com/config/containers/multi-service_container/). I personally have had most success with `supervisord`, which I will write separate notes for available [here](https://github.com/Dustpancake/Dust-Notes/blob/master/automation/supervisor-d.md).

The dockerfile only requires to copy in configurations and then set the entry-point
```Dockerfile
COPY 
supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
```

**NB:** in the `supervisord.conf` ensure you have
```
[supervisord]
nodaemon=true
```
for the supervisor configuration set.


## Discussions <a name="toc-sub-tag-2"></a>

### `ENTRYPOINT` vs `CMD` <a name="toc-sub-tag-3"></a>
TODO

### Good practices <a name="toc-sub-tag-4"></a>
TODO


## docker-compose
Recipes for docker-compose.

### MongoDB with MongoExpress
```yml
version: "3.8"

# Docker compose file for starting only the database environment for development

services:
    mongodb:
        image: mongo
        ports:
            - 27017:27017
            - 28017:28017
        volumes:
            - ./store:/data/db
        networks:
            - asteroid

    mongo_express:
        image: mongo-express
        ports:
            - 8081:8081
        environment:
            - ME_CONFIG_MONGODB_SERVER=mongodb
            - ME_CONFIG_MONGODB_PORT=27017
        networks:
            - asteroid
        depends_on:
            - mongodb
        restart: always

networks:
    asteroid:
```
