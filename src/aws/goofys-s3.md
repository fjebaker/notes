# Using Goofys with S3
[Goofys](https://github.com/kahing/goofys) filey system is a POSIX-like file system for use with S3 (or similar) cloud storage solutions.

- OSX


It can be installed in a variety of ways, as documented in the repository; for OSX, it requires the additional [`osxfuse` dependency](https://osxfuse.github.io/). The full installation is thus available with brew
```bash
brew cask install osxfuse
brew install goofys
```

## Mounting S3
We can mount an S3 bit bucket to our local file system with the command
```bash
goofys [bucketname] [path/to/mount]
```
which reads the `[default]` profile in `.aws/credentials`.

## Using MinIO
Goofys can also be used (although currently limited, though the *limit* isn't well documented) with [MinIO](https://min.io/); this requires a small amount of additional setup, namely creating a new profile in `.aws/credentials` with
```
[profile_name]
aws_access_key_id = YOUR_MINIO_ACCESS_KEY
aws_secret_access_key = YOUR_MINIO_SECRET_ACCESS_KEY  
```

We can then create the mount point, and, if needed, I would *encourage* the use of `chown` ; avoid running goofys as root for file permission reasons. There can also be some odd behaviour on OSX if trying to mount to `/Volumes/*`, which `chown` may be able to remedy.

Goofys accepts two additional flags to mount the MinIO bucket, namely
```bash
goofys \
  --profile YOUR_MINIO_PROFILE_NAME \
  --endpoint http://yourminio.server \
  [bucketname] [path to mount]
```
