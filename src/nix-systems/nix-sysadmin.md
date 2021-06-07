# System administration

Recipes and writeups of solutions from problems on different \*nix operating systems.

<!--BEGIN TOC-->
## Table of Contents
1. [Users and groups](#users-and-groups)
    1. [Creating new users](#creating-new-users)
    2. [Configuring shells](#configuring-shells)
    3. [`bindkey`](#bindkey)
    4. [Execute as user](#execute-as-user)
2. [Useful commands](#useful-commands)
    1. [`STOP` and `CONT` a process](#stop-and-cont-a-process)
    2. [SSL with `curl`](#ssl-with-curl)
    3. [`curl` proxies](#curl-proxies)
3. [Package management](#package-management)
4. [Path alternatives](#path-alternatives)
5. [Versions](#versions)
    1. [Debian](#debian)
    2. [Debian minor versioning](#debian-minor-versioning)
6. [Modifying keymaps with `xmodmap`](#modifying-keymaps-with-xmodmap)

<!--END TOC-->

## Users and groups

Listing all known users and groups
```bash
cat /etc/group
cat /etc/passwd
```

### Creating new users
Creating a **new user**, managing startup shell and directory
```bash
sudo useradd -d /home/[homedir] [username]
# -u for custom user id

sudo passwd [username]
# to change the password

sudo chsh -s /bin/bash [username]
# set startup shell
```
**NB:** The whole user creation process is also streamlined with the
```bash
sudo adduser [username]
```
interactive program.

For managing **primary groups**
```bash
sudo usermod -g [groupname] [username]
```

For managing **secondary groups**
```bash
sudo usermod -a -G [group1],[group2],[...] [username]
```

Removing a user from a group
```bash
sudo gpasswd -d user group
```

Deleting users
```bash
sudo userdel -r [username]
# -r removes home directory aswell
```

### Configuring shells
You can discover what shell your terminal is currently running by examining the `$SHELL` environment variable.

To see the available shells on your machine, use
```bash
cat /etc/shells
```

You can then change the default shell using
```bash
chsh
```
ran as the user you wish to change the shell for, or, alternatively
```bash
sudo chsh -s /bin/zsh someUser
```
to change the shell of `someUser` to `zsh`.

### `bindkey`
Bindkey controls how keyboard shortcuts on the terminal are mapped. This can be set in the relevant shell `~/.*rc` file. Common mappings are
```bash
bindkey -v
```
for vi-like map, and
```bash
bindkey -e
```
for emacs mapping.

**NB**: new and alternative shells may be installed via the relevant package managers.

### Execute as user
We can run commands as another user or with another group ID using `su`. For example, to run a command as another user
```bash
su someuser -c whoami
# someuser
```

Sometimes a user will not have a login shell defined, in which case `su` can spawn a specific shell as needed
```bash
su someuser -s /bin/bash -c "echo $SHELL"
# /bin/bash
```

The command can also be used to switch user. For example, to become root 
```bash
su -
```

## Useful commands
In this section I will document useful commands, which, for brevity, don't merit a full chapter of their own.

### `STOP` and `CONT` a process
As an example, consider you wanted to use Wireshark to capture packets of a specific program, however other programs were being very chatty, and working out exactly what Wireshark filter to craft is proving tedious. A quick and dirty solution to this is just to halt the execution of the chatty program

- find the `pid`:
We can find the process ID of any program using
```bash
ps aux | grep [name]
```

- send a `STOP` signal
Interrupt and halt the program using
```bash
kill -STOP [pid]
```

- resume with a `CONT` signal
Using a very similar command, we run
```bash
kill -CONT [pid]
```

### SSL with `curl`
https://stackoverflow.com/questions/10079707/https-connection-using-curl-from-command-line

### `curl` proxies
You can either set the environment variables
```
export http_proxy="http://uname:pw@addr:port"
export https_proxy="https://uname:pw@addr:port"
```
which `curl` automatically uses, or, pass in the flag `-x http://uname:pw@addr:port`.


## Package management
With `dpkg`, you can install with
```bash
dpkg -i [package].deb
```
list installations with
```bash
dpkg -l | grep [package_name]
```

Uninstall
```bash
dpkg -r [package_name]
```
and purge with `-P` instead of `-r`. Purge will also delete all configuration files.


## Path alternatives
You can adjust the priority of conflicting program versions, commonly [python3 vs python2](https://exitcode0.net/changing-the-default-python-version-in-debian/) using the `update-alternatives` command. The program linked with the highest priority will become the default
```bash
update-alternatives --install /usr/bin/python python /usr/bin/python3.8 2

update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
```
You can check the configuration with
```bash
update-alternatives --config python
```

## Versions
All sorts of valuable version information can be obtained with different commands, most of which are listed on [linuxconfig](https://linuxconfig.org/check-what-debian-version-you-are-running-on-your-linux-system).

### Debian
```bash
lsb_release -cs
# buster
```

```bash
cat /etc/issue
# Debian GNU/Linux 10 \n \l
```

```bash
cat /etc/os-release
# PRETTY_NAME="Debian GNU/Linux 10 (buster)"
# NAME="Debian GNU/Linux"
# VERSION_ID="10"
# VERSION="10 (buster)"
# VERSION_CODENAME=buster
# ID=debian
# HOME_URL="https://www.debian.org/"
# SUPPORT_URL="https://www.debian.org/support"
# BUG_REPORT_URL="https://bugs.debian.org/"
```

Useful tools
- `neofetch` for graphical system overview

The default tool for printing system information is `uname`. The most common use is probably for printing the machine hardware name (similar to `arch`)
```bash
uname -m
# x86_64
```
Another flag to remember is `-a`, which prints all information.

### Debian minor versioning
Although minor versions are a convenience measure (and thus, not included in e.g. `uname` or `/etc/os-release`), it can still be useful to know. The full debian version can be found with
```bash
cat /etc/debian_version
```

## Modifying keymaps with `xmodmap`
I don't like specific default [dead keys](https://en.wikipedia.org/wiki/Dead_key), such as the backtick symbol. To modify the behaviour of keys, we use `xmodmap`.

For my case, first identify the keycode using
```bash
xmodmap -pke | grep grave
```
and look for the output like 
```
keycode  21 = dead_circumflex dead_grave equal plus dead_tilde dead_ogonek dead_cedilla dead_ogonek
```
This will commonly be 21 or 49, depending on the nationality of your Keyboard.

We then copy the line, remove the `dead_` prefix from `grave`, and configure the mapping with 
```bash
xmodmap -e 'keycode  21 = dead_circumflex grave equal plus dead_tilde dead_ogonek dead_cedilla dead_ogonek'
``` 

To make this change permanent, we create a `~/.Xmodmap` dotfile with our modifications. Alternatively, to save an entire configuration, use
```bash
xmodmap -pke >> ~/.Xmodmap
```

We load the changes with
```bash
xmodmap ~/.Xmodmap
```

or to ensure the changes are ran when the X server inits, use
```bash
echo 'xmodmap ~/.Xmodmap' >> ~/.xinitrc
```

To undo a keyboard mapping, use
```bash
setxkbmap -option
```