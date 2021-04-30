# Bash cookbook

Solutions to common problems.

<!--BEGIN TOC-->
## Table of Contents
1. [Replacing newline characters](#replacing-newline-characters)

<!--END TOC-->

## Replacing newline characters

Comprehensively solved by [this SO answer](https://stackoverflow.com/a/7697604):

Use `tr`
```bash
tr '\n' ' ' < FILENAME
```

Tools like `sed` will not work, as they are fed line-by-line, and therefore never see newline characters.