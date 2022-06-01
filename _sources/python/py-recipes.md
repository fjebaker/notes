# Python recipes

Design patterns and solutions I commonly lookup, but are not specific enough to be group into their own notes page.

<!--BEGIN TOC-->
## Table of Contents
1. [Paths](#paths)
    1. [Crawling directories with `os.walk()`](#crawling-directories-with-os-walk)
    2. [Masking with `glob`](#masking-with-glob)

<!--END TOC-->

## Paths

### Crawling directories with `os.walk()`

To recursively crawl each directory in a given path
```python
for (dirpath, dirnames, filenames) in os.walk(root_path):
    ...
```
*Note:* to get the absolute path, use
```python
os.path.join(dirpath, filename)
```
in the `for` loop.

To get *just files* in the current directory, a pattern is
```python
_, _, filenames = next(os.walk("."))

# or error-safe
_, _, filenames = next(os.walk("."), (None, None, []))

# or if confident there will be at least one file
_, _, filenames = os.walk(".").next()
```

### Masking with `glob`

To use wildcard ([or `glob`](https://docs.python.org/3/library/glob.html)) expansion, we can use
```python
import glob
filenames = glob.glob("/path/to/dir/*.txt")
```
to mask for all `.txt` files. `glob` returns a list of *relative* paths.

*Note:* there also exists `glob.iglob` to return an iterator. Similarly, both commands have a `recursive` keyword argument (default `False`) for crawling directories.
