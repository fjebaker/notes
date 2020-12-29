# Debian Soundcards

<!--BEGIN TOC-->
## Table of Contents
1. [Sound Configuration](#toc-sub-tag-0)
	1. [ALSA](#toc-sub-tag-1)
		1. [CMUS with ALSA](#toc-sub-tag-2)
	2. [Hardware specifications](#toc-sub-tag-3)
<!--END TOC-->

## Sound Configuration <a name="toc-sub-tag-0"></a>
Especially on headless installations of \*nix, some sound device configuration is required.

**NB:** In most cases, the user wont succeed in configuring the sound unless they are also part of the `audio` group.

### ALSA <a name="toc-sub-tag-1"></a>
[Advanced Linux Sound Architecture](https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture) replaces the original Open Sound System (OSS) on \*nix.

There are conflicting methods for the installation on different \*nix systems, but I had personal success on Debian with
```bash
sudo apt-get install libasound2 alsa-utils alsa-oss
```

The seemingly magic configuration step that is missed out in a lot of guides is to create the file
```
/etc/modprobe.d/default.conf
```
with contents
```
options snd_hda_intel index=1
```
There is some information as to how this works in [this wiki entry](https://docs.slackware.com/howtos:hardware:audio_and_snd-hda-intel).

You'll probably also need to add
```
pcm.!default {
type hw
card 1
}

ctl.!default {
type hw
card 1
}
```
to `~/.asoundrc`, at least I did on Buster.

#### CMUS with ALSA <a name="toc-sub-tag-2"></a>
To get CMUS to use ALSA, we edit the `~/.cmus/autosave` file and change the configuration to
```
set dsp.alsa.device=default
set mixer.alsa.device=default
set mixer.alsa.channel=PCM
set output_plugin=alsa
```

If it fails to start, add the line
```
set output_plugin=alsa
```
in (a file which you'll probably have to create) `.cmus/rc`.


### Hardware specifications <a name="toc-sub-tag-3"></a>
As stated in the [Debian wiki](https://wiki.debian.org/ALSA#Troubleshooting), the assigned indexes to sound cards can be found with
```bash
cat /proc/asound/cards
```

To see the hardware device names, you can also use
```bash
lspci -nn | grep -i audio
```
Also useful is
```bash
lsmod | grep snd
```
to see the kernel sound modules.

With ALSA installed, you can also identify the sound devices using
```bash
aplay -l
```