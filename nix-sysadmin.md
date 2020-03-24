\*nix system administration cookbook
====================================

## Table of Contents
1. [Users and groups](#users-and-groups)

## Users and groups <a name="users-and-groups"></a>
Creating a **new user**, managing startup shell and directory
```
sudo useradd -d /home/[homedir] [username]
# -u for custom user id

sudo passwd [username]
# to change the password

sudo chsh -s /bin/bash [username]
# set startup shell
```

For managing **primary groups**
```
sudo usermod -g [groupname] [username]
```

For managing **secondary groups**
```
sudo usermod -a -G [group1],[group2],[...] [username]
```

Removing a user from a group
```
sudo gpasswd -d user group
```

Deleting users
```
sudo userdel -r [username]
# -r removes home directory aswell
```