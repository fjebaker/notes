# Networks

<!--BEGIN TOC-->
## Table of Contents
1. [Debian network configuration](#debian-network-configuration)
    1. [Controlling interfaces](#controlling-interfaces)
    2. [Configuring interfaces](#configuring-interfaces)
        1. [DHCP](#dhcp)
        2. [Static IP](#static-ip)
    3. [Debugging networks](#debugging-networks)
    4. [Proxies](#proxies)
2. [SSH recipes](#ssh-recipes)
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
Useful commands are

Copy login key to remote:

```bash
ssh-copy-id user@host
```
Remove host key from chain:
```bash
ssh-keygen -R host
```

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
A tool for investigating DNS lookups is `dig`, part of the `dnsutil` package.

To trace a DNS lookup, use
```bash
dig [server]
```

To trace a specific DNS server, use 
```bash
dig @192.168.1.254 [server]
```
