# `iptables` and firewall configuration reference.

Compiled from my commonly used commands, and nifty ones I've discovered in reading.

<!--BEGIN TOC-->
## Table of Contents
1. [Generic `iptables` commands](#generic-iptables-commands)
    1. [Logging with `iptables`](#logging-with-iptables)
    2. [State based rules](#state-based-rules)
    3. [Configuring firewall on startup](#configuring-firewall-on-startup)
2. [Marking traffic for special tables with `iproute2`](#marking-traffic-for-special-tables-with-iproute2)

<!--END TOC-->

## Generic `iptables` commands
Listing full iptables
```
iptables -L -n
# -L is list
# -n is ips and ports outputed as numbers
```
which is commonly used with `-t` to view specific tables, such as

1. `filter` -- the default table, with chains `INTPUT`, `FOWARD`, and `OUTPUT`.

2. `nat` -- for packets creating new connections, with `PREROUTING`, `INPUT`, `OUTPUT` and `POSTROUTING` chains.

3. `mangle` -- for specialized packet alterations. Includes `PREROUTING`, `OUTPUT`, `INPUT`, `FORWARD`, and `POSTROUTING`.

When adjusting tables, you can append `-A chain`, insert in a position `-I chain pos`, replace `-R chain pos`, and delete `-D chain pos`. To delete all rules in a chain, use `--flush [chain]`. Another useful flag is the policy `-P` flag, which may be either ACCEPT or DROP.

For selecting specific protocols, can use the `-p proto` flag, with tcp, icmp, udp, etc.

### Logging with `iptables`
Example use
```
iptables -A INPUT -m limit --limit 2/min -j LOG --log-prefix "iptables: " --log-level 4
```
which outputs all INPUT traffic to `/var/log/iptables.log`. Here the `-m` flag calls a match to limit, such that if the limit is exceeded, the match will return false and this entry will not execute. `-j` is the jump flag, saying that the target of the rule is the LOG extension, which includes the detail of different log levels.

(To view more on this, the manpage on `iptables-extensions` provides laborious detail.)

### State based rules
You could, for example, prevent new SSH sessions from `192.168.0.13` being created on the default port using 
```
iptables -A INPUT -p tcp -s 192.168.0.13 --dport 22 -m state --state NEW -j DROP
iptables -A OUTPUT -p tcp -d 192.168.0.13 --sport 22 -m state --state NEW -j DROP
```

Other states include ESTABLISHED, and RELATED.

### Configuring firewall on startup
Commonly just put an executable script in `/etc/network/if-up.d/` or `/etc/network/if-pre-up.d/`. If doing so, check the environment variable `$IFACE` so that the firewall is configured for the correct interface.

## Marking traffic for special tables with `iproute2`
