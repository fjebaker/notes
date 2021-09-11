
# Using NGiNX with Docker
In my use case, I had several VerneMQ Docker imagees running as a cluster, and wanted to use [NGiNX as a load balancer](https://www.nginx.com/blog/nginx-plus-iot-load-balancing-mqtt/) and client authentication server to seperate having to configure SSL certificates on every VerneMQ image.

As such, the default state of the install is as much/as little as the configuration obtained with
```bash
docker run --name mqtt-nginx -d -p 8080:80 -p 1883:1883 nginx
```
which can be quickly validated by visitng localhost:8080 in a web browser.

All of my experience so far has been with the free community edition of NGiNX.

<!--BEGIN TOC-->
## Table of Contents
1. [NGiNX as a Load Balancer](#nginx-as-a-load-balancer)
    1. [Configuration](#configuration)
    2. [Verifying](#verifying)

<!--END TOC-->

## NGiNX as a Load Balancer
The first task is to get NGiNX to distribute traffic amongst the different VerneMQ containers.

### Configuration
The configuration syntax of NGiNX is layered, and different keywords alter the behaviour of different protocols (e.g. `http` for HTTP, and `stream` for TCP).

We edit `/etc/nginx/nginx.conf` to include a new block
```
stream {
	include stream_conf.d/*.conf;
}
```
which directs NGiNX to load all of the `.conf` files in the `stream_conf.d` subdirectory, relative to `nginx.conf`. By convention, we do not use the default `conf.d` directory, since it is reserved for HTTP.

We'll create a very simple configuration file `/etc/nginx/stream_conf.d/stream_mqtt.conf` with the contents
```
log_format mqtt '$remote_addr [$time_local] $protocol $status $bytes_received ' 
                '$bytes_sent $upstream_addr';

upstream vernmq_cluster {
    server 192.168.1.136:11883;	# first server
    server 192.168.1.136:11884;	# second server
    server 192.168.1.136:11885;	# ...
    zone tcp_mem 64k;
}


server {
    listen 1883;
    proxy_pass vernmq_cluster;
    proxy_connect_timeout 1s;
	# health check is only in the commercial version

    access_log /var/log/nginx/mqtt_access.log mqtt;
    error_log  /var/log/nginx/mqtt_error.log; # Health check notifications
}
```
Here are defined the log formats, the upstream cluster (the `zone` directive defines the memory shared across NGiNX worker processes), and the actual TCP server configuration itself.

In the commercial version of NGiNX, health checks can be implemented, but the relevant packages are not included in the free version.

**NB:** I would personally recommend copying these files from the docker image, editing them in a more friendly text editor, and then copying them back over. The commands to copy can be found in my [Docker Cheatsheet](https://github.com/fjebaker/notes/blob/master/docker/docker-cheatsheet.md).

### Verifying
We can verify that the configuration files are acceptable by running the test command
```bash
nginx -t
```
inside the running container.

If all is well with out configuration, we can reload the NGiNX server with
```bash
nginx -s reload		# send a signal to the master process
service nginx restart
```
