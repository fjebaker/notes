# Bash cookbook

Solutions to common problems.

<!--BEGIN TOC-->
## Table of Contents
1. [Replacing newline characters](#replacing-newline-characters)
2. [Multi-pattern with `sed`](#multi-pattern-with-sed)

<!--END TOC-->

## Replacing newline characters

Comprehensively solved by [this SO answer](https://stackoverflow.com/a/7697604):

Use `tr`
```bash
tr '\n' ' ' < FILENAME
```

Tools like `sed` will not work, as they are fed line-by-line, and therefore never see newline characters.

## Multi-pattern with `sed`

To run several replacements with `sed` use
```bash
sed 's/ptrn1/replcm1/g; s/ptrn2/replcm2/g; ...'
```