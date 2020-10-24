# Using Docker as `systemd` services

Being able to launch Docker or `docker-compose` containers as system services can be very useful when administrating a larger server. To accomplish this, there are a few different solutions, utilising different mechanisms in how service files are executed -- as I find use cases for each, I will document them here.

## On installation and use
It is convention that server specific modifications are placed into `/etc/` and repository installed services in `/usr`. From `man 7 file-hierarchy`:
> ```        
>  /etc
>       System-specific configuration.

and

> ```
>  /usr
>       Vendor-supplied operating system resources.

Thus we want to symlink our `.service` files into `/etc/systemd/system`, and then use `enable` to correct link them into the `.target` and `.wants` directories. More on this can be read in [this SO answer](https://stackoverflow.com/questions/57496357/systemd-adding-service-into-multi-user-target-wants-folder-only-works-as-a-symli).

We link our service into the system search path with

```
sudo systemctl link [path]
```
and enable it with
```
sudo systemctl enable [service-name]
```


## `docker-compose` oneshots
Here is an example for a `docker-compose` service
```
[Unit]
Description=EXAMPLE
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/path/to/dir/with/docker-compose-file
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimoutStartSec=0

[Install]
WantedBy=multi-user.target
```
We use `oneshot` since it will only continue the service hierarchy after the process has exited. Since we have the docker `-d` flag, this process exits once the network and docker containers have been created.
