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

### The `-map` flag:
Different streams from input files can be mux'd together into the output file. To do this, we first need to identify the audio and video streams available in the input:

```
ffmpeg -i s0q0.m4s -i s1q1.m4s
```
which outputs
```
Input #0, mov,mp4,m4a,3gp,3g2,mj2, from 's0q0.m4s':
  Metadata:
    major_brand     : iso5
    minor_version   : 512
    compatible_brands: iso6mp41
    encoder         : Lavf58.29.100
  Duration: 02:40:07.65, start: 0.000000, bitrate: 65 kb/s
    Stream #0:0(eng): Audio: aac (LC) (mp4a / 0x6134706D), 44100 Hz, mono, fltp, 63 kb/s (default)
    Metadata:
      handler_name    : #Mainconcept MP4 Sound Media Handler
Input #1, mov,mp4,m4a,3gp,3g2,mj2, from 's1q1.m4s':
  Metadata:
    major_brand     : iso5
    minor_version   : 512
    compatible_brands: iso6mp41
    encoder         : Lavf58.29.100
  Duration: 02:40:07.80, start: 0.160000, bitrate: 201 kb/s
    Stream #1:0(eng): Video: h264 (High) (avc1 / 0x31637661), yuv420p, 1730x1080 [SAR 1:1 DAR 173:108], 199 kb/s, SAR 17820:17819 DAR 165:103, 25 fps, 25 tbr, 12800 tbn, 50 tbc (default)
    Metadata:
      handler_name    : ?Mainconcept Video Media Handler
```
We can index the audio and videos using the formatter `[inputID]:{a|v}:[streamID]`. So for the above example, we can merge audio from `s0q0.m4s` and video from `s1q1.m4s` with the command
```
ffmpeg -i s0q0.m4s -i s1q1.m4s -c copy -map 0:a:0 -map 1:v:0 -shortest out.mp4
```

The `-shortest` flag ensures that if the timestamps for the two inputs are slightly different, we reduce the output to the length of the shortest.