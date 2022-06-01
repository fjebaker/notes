# EC2 with Docker

Once a Docker image has been created on your local machine, it can easily be run on an EC2 instance and made accessible to public networks.

<!--BEGIN TOC-->
## Table of Contents
1. [Launching EC2 instances](#launching-ec2-instances)
    1. [Connecting via ssh](#connecting-via-ssh)
2. [Using Docker containers](#using-docker-containers)
    1. [Configuring Docker on EC2](#configuring-docker-on-ec2)
    2. [Running your Docker container](#running-your-docker-container)

<!--END TOC-->

## Launching EC2 instances
From the AWS control panel, EC2 instances can quickly be spun up and tared down. It's pretty easy to accidentally accrue charges, so when creating the instance ensure you only use free tier options.

It is useful in the `tags` section to create a 'Name' tag, since that will appear on billing invoices, so you can quickly identify which service is costing you.

Also make sure that your VPC security group has port 22 exposed for at least your IP address, else you will not be able to connect to the instance. After launching the instance, you will either create or reuse an SSH identity key, i.e. some `.pem` file. You use this file to authenticate your SSH login.

### Connecting via ssh
SSH requires your key to have specific permissions so that it cannot accidentally be modified; i.e. run 
```
sudo chmod 400 [key].pem
```
and then connect to the EC instance with username `ec2-user` (you can find the IP address under the info tab for your instance on the AWS control panel):
```
ssh -i [key].pem ec2-user@[public-ip]
```
The instances can be a little outdated, so it is highly recommended to run
```
sudo yum update -y
```
or the equivalent, before doing anything else.

## Using Docker containers
Amazon provides a special set of integrated tools that can be installed on EC2 instances, such as gimp, libreoffice, or, for our purposes, Docker.

### Configuring Docker on EC2
To install the docker prerequisites, run
```
sudo amazon-linux-extras install docker
```
and set Docker running as a service so that it persists after log-offs
```
sudo service docker start
```
Finally, so you don't have to run every Docker command as `sudo`, add yourself to the `docker` group
```
sudo usermod -a -G docker ec2-user
```
Note, if you want Docker to persist upon shutdown and restart, you must enable the service with 
```
sudo systemctl enable docker
```


### Running your Docker container
Once you have built an image, you can save it as a `.tar` file for distribution using
```
docker save -o [filename].tar [image_name]
```
SCP copy this `.tar` to the EC2 instance, and then remotely use
```
docker load -i [filename].tar
```
to load the image into the Docker image list. You can now run the image using
```
docker run [image_name]
```
or disconnected from a shell by including the `-d` flag. This way, the docker image will still run after log-off (NB this requires Docker to be running as a service). If you are exposing docker ports, ensure they are configured correctly in the VPC. To bind ports use, e.g., `-p 8080:8080`.

To stop the container, use
```
docker stop CONTAINER_ID
```
and remove it with
```
docker rm CONTAINER_ID
```
