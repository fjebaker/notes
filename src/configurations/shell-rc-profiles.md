# Shell `.*rc` and `.*profile` configurations

Some of the common configurations I tend to use for bash shells. My commonly used `.bashrc` files for different environments are 

- Debian [`.bashrc`](https://github.com/dustpancake/dust-notes/blob/master/src/configurations/debian.bashrc.sh)
- \*nix [`.zshrc`](https://github.com/dustpancake/dust-notes/blob/master/src/configurations/nix.zshrc.sh)
- OSX [`.zprofile`](https://github.com/dustpancake/dust-notes/blob/master/src/configurations/osx.zprofile.sh)

<!--BEGIN TOC-->
## Table of Contents
1. [`zsh` startup files](#zsh-startup-files)

<!--END TOC-->

## `zsh` startup files
Taken from [the docs](https://zsh.sourceforge.io/Intro/intro_3.html), `zsh` reads from 5 different startup files
```
$ZDOTDIR/.zshenv
$ZDOTDIR/.zprofile
$ZDOTDIR/.zshrc
$ZDOTDIR/.zlogin
$ZDOTDIR/.zlogout
```

If `$ZDOTDIR` is unset, it defaults to the home directory.

`.zshenv` is used on all shell invocations, unless with the `-f` (no-rcs) flag is passed. From the docs
> It should contain commands to set the command search path, plus other important environment variables. `.zshenv` should not contain commands that produce output or assume the shell is attached to a tty.

This is in contrast to
> `.zshrc` is sourced in interactive shells. It should contain commands to set up aliases, functions, options, key bindings, etc. 