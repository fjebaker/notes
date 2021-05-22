# Bash cookbook

Solutions to common problems.

<!--BEGIN TOC-->
## Table of Contents
1. [Replacing newline characters](#replacing-newline-characters)
2. [`sed`](#sed)
    1. [Dealing with special characters](#dealing-with-special-characters)
    2. [Multi-pattern with `sed`](#multi-pattern-with-sed)
3. [`nohup` with `sudo`](#nohup-with-sudo)
4. [Command after time](#command-after-time)

<!--END TOC-->

## Replacing newline characters

Comprehensively solved by [this SO answer](https://stackoverflow.com/a/7697604):

Use `tr`
```bash
tr '\n' ' ' < FILENAME
```

Tools like `sed` will not work, as they are fed line-by-line, and therefore never see newline characters.

## `sed`

### Alternative and escaped seperators 
When using `sed` on e.g. urls, string characters like `/` can be bothersome, especially when stored in a variable. `sed` provides, however, the functionality to change the seperator.

In standard operations, this looks like
```bash
sed 's%ptrn1%replcm1%g'
```
where the character immediately after `s` denotes the seperator.

In other operations, such as delete, the same can be accomplished by escaping the first seperator:
```bash
sed '\|pattern to delete|d'
```

### Multi-pattern with `sed`

To run several replacements with `sed` use
```bash
sed 's/ptrn1/replcm1/g; s/ptrn2/replcm2/g; ...'
```

## `nohup` with `sudo`

A common design pattern is to background (`&`) a command with `sudo` with `nohup`. Naively sticking `sudo` as a prefix means that `sudo` will be run in the background, and not the `nohup` process. Instead, use the *run as background process* flag `-b`:

```bash
sudo -b nohup MY_COMMAND 
```

## Command after time
To run a command after a certain time interval
```bash
sleep 60s && MY_COMMAND
```
*Note:* the use of `&&` instead of e.g. `;` is so that cancelling the sleep command also cancells `MY_COMMAND`.

To run a process and kill it after a certain amount of time, use
```bash
MY_COMMAND & pid=$! ; sleep 1m && kill $pid
```
Alternatively, background the termination process using a subshell
```bash
MY_COMMAND & pid=$! ; ( sleep 1m && kill $pid ) &
```

See [this Stack Overflow answer](https://serverfault.com/a/903631) for obtaining PIDs ahead of time.