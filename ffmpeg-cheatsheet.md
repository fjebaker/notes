# FFMPEG Cheatsheet
Compiled from commands I find myself using frequently.

Generic niave trial is just to use
```
ffmpeg -i input.ext1 output.ext2
```
and if it fails, tinker. Below are some common tinkers to fix common problems.

### Converting video
For `.mp4` to `.mp3` with correct time-stamping
```
ffmpeg -i video.mp4 -b:a 192K -vn audio.mp3

# -b:a is audio bit rate
# -vn blocks all video streams from being selected
```

For `.mp4` to `.wav`
```
ffmpeg -i video.mp4 -ab 160k -ac 2 -ar 44100 -vn audio.wav

# -ac is audio channels
# -ar is audio sample rate
```

### Converting streams
Downloading from `.m3u8` files
```
ffmpeg -i [url to m3u8 file] -c copy -bsf:a aac_adtstoasc output.mp4
```
Can also include comma seperated string list of headers using the `-headers` flag.