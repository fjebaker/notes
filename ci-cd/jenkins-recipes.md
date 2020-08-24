# Jenkins Cookbook
I am in the process of reconfiguring CI/CD for a new project I am working on, and decided to document for ease of future-reuse, all the usual stuff I take notes on, but now for [Jenkins](https://www.jenkins.io).

<!--BEGIN TOC-->
## Table of Contents
1. [Jenkins quick-start with Docker](#toc-sub-tag-0)
	1. [Creating the prerequisites](#toc-sub-tag-1)
	2. [Running Jenkins](#toc-sub-tag-2)
2. [Python-Jenkins worked example](#toc-sub-tag-3)
<!--END TOC-->

## Jenkins quick-start with Docker <a name="toc-sub-tag-0"></a>
The latest image for jenkins is [`jenkinsci/blueocean`](https://hub.docker.com/r/jenkinsci/blueocean/), obtainable with the usual 
```bash
docker pull jenkinsci/blueocean
```
We will also use the `docker:dind` image:
```bash
docker image pull docker:dind
```

This setup follows the [official documentation](https://www.jenkins.io/doc/book/installing/).

### Creating the prerequisites <a name="toc-sub-tag-1"></a>
Jenkins requires a docker network and (recommended) two docker volumes. We can create the bridged network and simple default volumes with
```bash
docker network create jenkins
# for TLS certificates 
docker volume create jenkins-docker-certs
docker volume create jenkins-data
```
We will require use of Docker-In-Docker `docker:dind`, so that Jenkins can spin up and manage containers. We run this command to configure this:

```bash
docker container run \
  --name jenkins-docker \
  --rm \
  -d \
  --privileged \
  --network jenkins \
  --network-alias docker \
  -e DOCKER_TLS_CERTDIR=/certs \
  -v jenkins-docker-certs:/certs/client \
  -v jenkins-data:/var/jenkins_home \
  -p 2376:2376 \
  docker:dind
```

### Running Jenkins <a name="toc-sub-tag-2"></a>
To start the jenkins service, we will use
```bash
docker container run \
  --name jenkins-blueocean \
  --rm \
  -d \
  --network jenkins \
  -e DOCKER_HOST=tcp://docker:2376 \
  -e DOCKER_CERT_PATH=/certs/client \
  -e DOCKER_TLS_VERIFY=1 \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins-data:/var/jenkins_home \
  -v jenkins-docker-certs:/certs/client:ro \
  jenkinsci/blueocean
```

Then visit [`http://localhost:8080`](http://localhost:8080) to enter setup.


## Python-Jenkins worked example <a name="toc-sub-tag-3"></a>
Following from tutorials on the Jenkins website, primarily [this example](https://www.jenkins.io/doc/tutorials/build-a-python-app-with-pyinstaller/).
