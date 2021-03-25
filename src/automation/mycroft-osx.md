# Using Mycroft Docker images on OSX

<!--BEGIN TOC-->
## Table of Contents

<!--END TOC-->

Following from the ["Get Mycroft" instructions](https://mycroft.ai/get-started/), we can obtain a docker image with
```bash
docker pull mycroftai/docker-mycroft
```

To enable the sound devices, we require PulseAudio, which we can install on OSX with brew
```bash
brew install pulseaudio
```

It is presented to start the pulseaudio daemon with `brew services`, however for our specific use case, we instead want to manage the daemon ourselves, and use the command
```bash
pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
```
to initialise the daemon.


Next, we'll create a startup, persistent-volume script
```bash
#!/bin/bash
docker run --rm -d \
        -v /PATH/TO/DATA/DIR:/root/.mycroft \
        -e PULSE_SERVER=host.docker.internal \
        --mount type=bind,source=/PATH/TO/HOME/.config/pulse,target=/root/.config/pulse \
        -p 8181:8181 \
        --name mycroft \
        mycroftai/docker-mycroft
```
Note there are two paths in the above which are system specific, and must be absolute. I use `/PATH/TO/HOME` instead of `~`, since the Docker `--mount` directive required absolutes. We use `--mount` over `-v` to prevent root access complications.

That's it! The rest of the setup is guided by Mycroft repeatedly speaking to you until you've registered the device on the [homepage](https://mycroft.ai/).
