# FFMPEG Cheatsheet
Compiled from commands I find myself using frequently.

Generic niave trial is just to use
```
ffmpeg -i input.ext1 output.ext2
```
and if it fails, tinker. Below are some common tinkers to fix common problems.

For HTTP proxies, use the `-http_proxy [addr]` flag.

<!--BEGIN TOC-->
## Table of Contents
1. [Converting video](#converting-video)
2. [Converting streams](#converting-streams)
3. [The `-map` flag](#the--map-flag)
4. [Embedding subtitles](#embedding-subtitles)
5. [Concatenation](#concatenation)
    1. [Concatenating videos](#concatenating-videos)
    2. [Concatenating images into videos](#concatenating-images-into-videos)

<!--END TOC-->

## Converting video
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


## Converting streams
Downloading from `.m3u8` files
```
ffmpeg -i [url to m3u8 file] -c copy -bsf:a aac_adtstoasc output.mp4
```
Can also include comma seperated string list of headers using the `-headers` flag.

## The `-map` flag
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

## Embedding subtitles
For a given `.srt` file, the subtitles can be embedded into an `.mp4` using
```
ffmpeg -i [videos].mp4 -i [subtitles].srt -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 language=eng out.mp4
```
Here we are copying the video and audio channels from the input video, and copying subtitles with `-c:s mov_text`. We also use the metadata mapper to change the subtitle stream (`:s:s:0`, c.f. e.g. audio `:s:a:1`) language to `eng`.

## Concatenation

### Concatenating videos
To concatenate videos, create a file containing an ordered list of videos to be concatenated
```
file 'part1.mp4'
file 'part2.mp4'
...
```
Then pass this file to `ffmpeg` with
```bash
ffmpeg -f concat -safe 0 -i infile.txt output.mp4
```
The safe options is disable the unsafe filename error. From the docs:

> safe 
> If set to 1, reject unsafe file paths. A file path is considered safe if it does not contain a protocol specification and is relative and all components only contain characters from the portable character set (letters, digits, period, underscore and hyphen) and have no period at the beginning of a component.
> 
> If set to 0, any file name is accepted.

### Concatenating images into videos
There are many commands that can achieve this result. For the problem I was solving, I wanted to concatenate PNG images, numbered `1.png`, `2.png`, `...`, into a `.mp4` video at a specific frame rate
```
ffmpeg -f image2 -r [framerate] -i %d.png -vcodec mpeg4 -y out.mp4
```
