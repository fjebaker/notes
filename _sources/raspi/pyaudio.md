# Installing PyAudio on Raspberry Pi

<!--BEGIN TOC-->
## Table of Contents
1. [Setup](#setup)
2. [A note on the default audio device <a name="toc-sub-tag-0"></a>](#a-note-on-the-default-audio-device-<a-name="toc-sub-tag-0"></a>)
3. [Making pulesaudio an enabled service <a name="toc-sub-tag-1"></a>](#making-pulesaudio-an-enabled-service-<a-name="toc-sub-tag-1"></a>)
4. [Listing PyAudio devices <a name="toc-sub-tag-2"></a>](#listing-pyaudio-devices-<a-name="toc-sub-tag-2"></a>)

<!--END TOC-->

## Setup

Using the raspian operating system. The required packages are
```bash
(sudo apt-get update && sudo-apt get upgrade)
sudo apt-get install portaudio19-dev pulseaudio
```
Pulseaudio seems to be required for translating the audio device indexes for PyAudio. Since we want it to run as a daemon, we must start it with
```bash
pulseaudio --start
```
Then, in the python environment we install
```bash
pip install pyaudio 
```
and use a test script to ensure the behaviour is as desired, e.g. a minimal
```python
import wave, pyaudio
testfile = "test.wav"

with wave.open(testfile, 'rb') as wf:
	prop = {}
	prop['rate'] = wf.getframerate()
    prop['format'] = self._p.get_format_from_width(wf.getsampwidth())
	prop['channels'] = wf.getnchannels()
    prop['output'] = True
    prop['output_device_index'] = None 	# change to desired, else None uses default

    pa = pyaudio.PyAudio()
    stream = pa.open(**prop)

    data = wf.readframes(1024)
    while len(data) > 0:
    	stream.write(data)
    	data = wf.readframes(1024)

    stream.stop_stream()
    stream.close()

    pa.terminate()
```
## A note on the default audio device <a name="toc-sub-tag-0"></a>
To view the default audio device used by PyAudio, use
```python
import pyaudio
pa = pyaudio.PyAudio()
pa.get_default_output_device_info()
```


## Making pulesaudio an enabled service <a name="toc-sub-tag-1"></a>
We can make pulseaudio auto-start with `systemd` by creating a file in `/etc/systemd/system/pulseaudio.service` with contents
```
[Unit]
Description=Pulseaudio system daemon

[Service]
Type=notify
Exec=pulseaudio --system --realtime --daemonize=no

[Install]
WantedBy=multi-user.target
```
note that in this case we want to explicitly set `daemonize=no` for the program, else we cannot control it with `systemctl`. Additionally, in the manual pages, the `--start` flag implies `daemonize`, so cannot start it in the same way as we would on the command line. The `--system` flag enables the service across the whole system, instead of on a per user basis, and the `--realtime` flag helps synchronize the audio threads when running in `system` mode.

Enable and start the service
```
sudo systemctl --system enable pulseaudio.service
sudo systemctl --system start pulseaudio.service
``` 

Also note that interacting with this service using `systemctl` requires the **`--system`** flag, e.g. `sudo systemctl --system status pulseaudio`.

## Listing PyAudio devices <a name="toc-sub-tag-2"></a>
To list the audio devices PyAudio is able to interact with, use
```python
import pyaudio
p = pyaudio.PyAudio()
for i in range(p.get_device_count()):
    print(p.get_device_info_by_index(i).get('name'))
```