# Clam Anti Virus

[ClamAV](https://docs.clamav.net/) is an open source anti virus program licensed under GPLv2. It installs on nearly all systems, and provides a direct and daemon scanning mode.

## Installation
Installing ClamAV with the `clamd` daemon with `apt`:
```bash
sudo apt-get install clamav clamav-daemon
```
This will do a number of things, including creating a new user `clamav`, and generate example configs in `/etc/clamav`. 

If `freshclam` did not automatically start, either run `freshclam` as a daemon (`-d`), or directly to update the signatures database.

### Configuration
Configuration files are found in `/etc/clamav`. If you have a file `*.conf.example` but no `*.conf`, rename the examples to remove the `.example` suffix and remove the comment
```
#Example
```
from the file, else `clamd` will consider the configuration invalid.

There are a few options which are worth drawing attention to
```
# Permissions on the unix socket
LocalSocketMode 660

# Maximum filesize to scan
MaxFilesize 20

# Maximum scan size of a given file
MaxScanSize 20
```

Use `clamconf` to print the current configuration.

For more, see the [docs](https://docs.clamav.net/manual/Usage/Configuration.html).


## Scanning

### `clamscan`
`clamscan` is the one-time scanning command line tool from `libclamav`. As you can see in the [docs](https://docs.clamav.net/manual/Usage/Scanning.html#clamscan), it accepts a variety of options, with more options listed in the manual.

### `clamd/clamdscan`
Tasks are queued with `clamdscan` to the Clam daemon. At any given moment, the tasks queued can be viewed with `clantop`. Depending on your permission and socket/streaming configurations, you may need to use the `--fdpass` (file descriptor pass) option when using `clamdscan`.

In general, `clamdscan` accepts a far smaller set of options than `clamscan`, and will ignore options it cannot handle. This is because the configuration of the scanner takes place at the daemon level.

When using `clamdscan`, a useful option to pass is `-m, --multiscan` which will leverage threading in scanning a directory.

### Recipes
In the following, `clamscan` and `clamdscan` can be used interchangeably, provided they have been configured correctly.

- scan the current directory recursively only listing infected files
```bash
clamscan -i .
```

- scan and remove infected files
```bash
clamscan --remove .
```

