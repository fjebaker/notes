# Networks

<!--BEGIN TOC-->
## Table of Contents
1. [Debian network configuration](#debian-network-configuration)
    1. [Controlling interfaces](#controlling-interfaces)
    2. [Configuring interfaces](#configuring-interfaces)
        1. [DHCP](#dhcp)
        2. [Static IP](#static-ip)
        3. [DNS](#dns)
    3. [Debugging networks](#debugging-networks)
    4. [Proxies](#proxies)
2. [SSH recipes](#ssh-recipes)
    1. [SSH string tokens](#ssh-string-tokens)
    2. [Configuration files](#configuration-files)
    3. [Debugging access rights](#debugging-access-rights)
    4. [Connection pooling](#connection-pooling)
    5. [Tunneling](#tunneling)
3. [Network introspection](#network-introspection)
    1. [Checking open ports](#checking-open-ports)
    2. [ARP](#arp)
    3. [DNS interrogation](#dns-interrogation)

<!--END TOC-->

## Debian network configuration
Whilst installing Debian 9 on an old machine, which had a faulty NIC, I learned a few things about network configurations on that specific OS, most of which is documented [in the manual](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html).

The legacy `ifconfig` is being replaced with the newer `ip` suite, and an overview of the translation can be quickly seen in this post by [ComputingForGeeks](https://computingforgeeks.com/ifconfig-vs-ip-usage-guide-on-linux/). Two very useful commands I use a lot for debugging are
```bash
ip a 	# output similar to the standard ifconfig

ip -s link show [interface]	# outputs interface statistics
```


### Controlling interfaces
Toggling specific interface states can be done using either `ip`
```bash
ip link set [interface] up
```
or `ifup`/`ifdown`
```bash
ifup [interface]
ifdown [interface]
```
**NB:** `ifup` and `ifdown` can only interact with interfaces defined in `/etc/network/interfaces`. Add a simple configuration, such as
```
iface [enoXYZ] inet dhcp
```
More detail on this in the next section.

The whole network interface may be interacted with using the `init.d` service
```bash
sudo /etc/init.d/networking [start, stop, restart, status]
```
or with `systemd` using
```bash
sudo systemctl [start, stop, restart, status] networking
```


### Configuring interfaces
A post on [nixCraft](https://www.cyberciti.biz/faq/howto-configuring-network-interface-cards-on-debian/) provides a good overview of Debian network configuration, and the configuration syntax can be seen [in the manual](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_basic_syntax_of_etc_network_interfaces).

The main interfaces configuration can be edited in
```bash
/etc/network/interfaces
```
and typically includes just a necessary (?) local configuration
```
auto lo
iface lo inet loopback
```

#### DHCP
For a DHCP interface, we can use a simple configuration such as
```
auto eth0
iface eth0 inet dhcp
```

#### Static IP
Static IP addresses can be assigned with
```
auto eth0
iface eth0 inet static
	address 192.168.xxx.yyy
	netmask 255.255.255.0
	gateway 192.168.1.1
	# dns-domain example.com
	# dns-nameserver 192.168.1.1
```
As pointed out [in the manual](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_network_interface_with_the_static_ip), if `resolvconf` package is not installed, the DNS configuration is done by editing the `/etc/resolv.conf` file with, for example
```
nameserver 192.168.1.1
domain example.com
```

**NB:** The modern `systemd` configuration is considerably more elegant, and also documented [in the manual](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_modern_network_configuration_without_gui).

#### DNS
The DNS servers are configured (on `systemd` distributions) through `dhcpcd`, and thus may be amended by editing
```
/etc/dhcpcd.conf
```
and adding the line
```
static domain_name_servers=address [address, ...]
```

### Debugging networks
See [this guide on port overviews](https://linuxize.com/post/check-listening-ports-linux/).

### Proxies

To configure proxies for the currently running shell, simply define the environment variables
```bash
export http_proxy=""
export https_proxy=""
```
These are read by most common command line programs, such as `curl`, or `wget`.

*NB:* other environment variables include `ftp_proxy`, `socks_proxy`, or `all_proxy`. The format for the url is
```
protocol://user:password@host:port
```


## SSH recipes
A handful of useful tips and tricks when using SSH.

Copy login key to remote:

```bash
ssh-copy-id user@host
```

Remove host key from chain:
```bash
ssh-keygen -R host
```

### SSH string tokens

These tokens are expanded from strings at runtime. From `man ssh_config`:

```
%%    A literal ‘%’.
%C    Hash of %l%h%p%r.
%d    Local user's home directory.
%h    The remote hostname.
%i    The local user ID.
%k    The host key alias if specified, otherwise the orignal remote
        hostname given on the command line.
%L    The local hostname.
%l    The local hostname, including the domain name.
%n    The original remote hostname, as given on the command line.
%p    The remote port.
%r    The remote username.
%T    The local tun(4) or tap(4) network interface assigned if tun‐
        nel forwarding was requested, or "NONE" otherwise.
%u    The local username.
```

### Configuration files

Configuration files can help assign different SSH identities or options to different hosts. The global configuration file is located in `/etc/ssh/ssh_config`, and the per user in `~/.ssh/config`.

The configuration files are of the format
```
Host hostname1
    SSH_OPTION value
    SSH_OPTION value
    ...

Host hostname2
    ...
```

A full overview of the configuration files can be found [on the SSH website](https://www.ssh.com/academy/ssh/config).

An example configuration for using a specific identity with a specific host
```
Host github.com
    IdentityFile ~/.ssh/id_github
    IdentitiesOnly yes
```

Another example for creating an alias
```
Host *pi
    HostName huginn.local
    User pi
    Port 22
```
Now using any of the following
```bash
ssh pi
ssh raspberrypi
ssh mypi
```
will all use the above configuration and alias to
```bash
ssh pi@huginn.local -p 22
```


### Debugging access rights
The best way to understand what is going wrong is just to trace a verbose test connection
```bash
ssh -T user@domain -v
```

### Connection pooling

To avoid having to execute a full SSH handshake, or if connections are being rate-limited, we can use the `ControlMaster` and `ControlPath` options of SSH. From `man ssh_config`:

> ```
> ControlMaster
>         Enables the sharing of multiple sessions over a single network
>         connection.  
> ...
> ControlPath
>         Specify the path to the control socket used for connection shar‐
>         ing as described in the ControlMaster section above or the string
>         none to disable connection sharing.  
> ```

In practice, we can open a socket, e.g. `.conn.sock`, via a master connection, and then direct other SSH commands to use this socket:
```bash
ssh -S .conn.sock -M host
```
Then, in a second terminal:
```
ssh -S .conn.sock host "echo Hello World"
```

To avoid having to ensure sockets have a sane name and are cleaned up, it may also be worth adding 
```
ControlPath ~/.ssh/control-%h-%p-%r
```
into your SSH configuration file

### Tunneling

The `ssh` program supports *tunneling*, which allows a machine to forward ports via SSH to another machine. This can be used to make e.g. secure web-connection, or just to forward SSH traffic.

From the `ssh` manual, the `-L` flag allows us to forward, or *tunnel*, traffic from one machine through to another.
> ```
> -L [bind_address:]port:host:hostport
> -L [bind_address:]port:remote_socket
> -L local_socket:host:hostport
> -L local_socket:remote_socket
> ```

Our aim then is to expose a port on our local machine (PC), which will send traffic via `ssh` to `remote1`, which will in turn forward this traffic to `remote2`. We can do this with

```bash
ssh -N -L localhost:12001:remote2:22 USER@remote1
```
- `-N`: Do not execute a remote command on Aquila.
- `-L localhost:12001:remote2:22` bind port `12001` on our local machine (PC), such that when a connection is made to this port, it will be forwarded, via 

## Network introspection

### Checking open ports
Using the `netstat` command
```bash
netstat -tunlp
```
with the flags for `-p` process id associated, `-u` udp connections, `-n` display numerical port range, `-t` tcp connections, and `-l` to show listening sockets.

*NB:* `netstat` is increasingly deprecated in favour of `ss`.

This can also be accomplished using the `lsof` to list open files
```bash
lsof -i
```
where we use the `-i` flag to select listings with internet addresses. This can be further specified e.g. `-i tcp`.

Or with `nmap`, TCP
```bash
nmap -sT -O localhost
```
or, for UDP
```bash
nmap -sU localhost
```

To discover which process is listening on a specific port, e.g. `4242`, we can use
```bash
lsof -nP -iTCP:4242 -sTCP:LISTEN
```

Finally, there is also `ss`, another socket investigating utility. To list listening ports with `ss`, similar to `netstat`, use
```bash
ss -tunlp
``` 

### ARP
ARP, or Address Resolution Protocol, maps IP addresses to MAC addresses in a LAN, allowing devices to find one another.

To interact with the ARP cache (known IP-MAC resolutions), we use [`arp`](https://manpages.debian.org/buster/net-tools/arp.8.en.html), which is installed as part of the [`net-tools` package](https://manpages.debian.org/buster/net-tools/index.html).

- viewing the full ARP cache
```bash
arp -a

# saturn.home (192.168.1.136) at 00:00:00:00:00:01 [ether] on enp4s0
# internetbox.home (192.168.1.1) at 00:00:00:00:00:02 [ether] on enp4s0
```
- find MAC for specific IP
```bash
arp -a 192.168.1.136

# saturn.home (192.168.1.136) at 00:00:00:00:00:01 [ether] on enp4s0
```

*Note*: there is BSD and Linux output style (`-a` vs `-e`).

ARP cache entries can either be *static* or *dynamic*, i.e. user-added, or automatically resolved. 

### DNS interrogation
A tool for investigating DNS lookups is [`dig`](https://linux.die.net/man/1/dig), part of the `dnsutil` package.

To trace a DNS lookup, use
```bash
dig [server]
```

To trace a specific DNS server, use 
```bash
dig @192.168.1.254 [server]
```

The same may be accomplished using [the `nslookup` program](https://man.cx/nslookup(1)) (included as part of `distutils`):
```bash
nslookup [server]
```

You can also view the current DNS configuration by viewing
```bash
cat /etc/resolv.conf
```

