
# OSX Reference

Notes, recipes, and useful snippets relating to all things OSX.

<!--BEGIN TOC-->
## Table of Contents
1. [Changing hostnames:](#changing-hostnames)

<!--END TOC-->

## Changing hostnames:
Use `scutil`, a program from managing system configuration parameters.

To change primary hostname
```bash
sudo scutil --set HostName [hostname]
```
Bonjour hostname:
```bash
sudo scutil --set LocalHostName [hostname]
```
Computer name
```bash
sudo scutil --set ComputerName [hostname]
```

Then flush the DNS cache with
```bash
dscacheutil -flushcache
```

and reboot.