# Virtual Machines with OSX Hosts
Using [Oracle VirtualBox](https://www.virtualbox.org/), installed using brew with extensions:

```bash
brew cask install virtualbox  virtualbox-extension-pack
```

## Linux Images
In general, setting up a Linux VM is relatively configuration-free -- following the regular method for creating a new image, unless a fairly unknown distribution of Linux is being used, VirtualBox already configures most of the settings for you.

There is however a slight exception at time of writing (23 September 2020), and that is that with OSX hosts, the new Audio Driver causes the machine to crash (my investigation of this is about a week old and I have lost the logs and research since -- this will be updated when I inevitably recreate the problem in the future).

The problem is as follows
- after installation is complete, during reboot the image will crash showing status *aborted*
- subsequent boot attempts recreate the above

The prescription is simple:
- in Settings/Audio, uncheck Enable Audio, *or*
- use a different audio driver on the Host
