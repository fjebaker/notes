# Using the `re` library in Python 
The regex implementation in Python comes with a unique set of commands for facilitating matches, searches, substitutions, and other operations.

Regular expressions in Python should be defined as raw strings types, i.e.
```python
ptrn = r"some patern"
```

<!--BEGIN TOC-->
## Table of Contents
1. [The `re.Match` object](#toc-sub-tag-0)
2. [Flags and pre-compilation](#toc-sub-tag-1)
3. [Functions](#toc-sub-tag-2)
	1. [Splitting strings with `split`](#toc-sub-tag-3)
	2. [Searching with `search`](#toc-sub-tag-4)
	3. [Extracting groups with `findall`](#toc-sub-tag-5)
	4. [`finditer`](#toc-sub-tag-6)
	5. [Replacing with `sub` and `subn`](#toc-sub-tag-7)
<!--END TOC-->


## The `re.Match` object <a name="toc-sub-tag-0"></a>
The `re.Match` object contains the result of many regex methods. It has member functions for extracting groups with `group` and `groups`, methods for finding the index of the matches (returning tupples of starts and ends) with the `regs` property.

It also contains the matched string in the `string` property.

## Flags and pre-compilation <a name="toc-sub-tag-1"></a>
You can pre-compile regex expressions using `re.compile(expr, *flags)`, where the flags are defined in the library. Commonly used are 

- `re.MULTILINE` for matching over many new line characters
- `re.GLOBAL` for matching many occurances 
- `re.IGNORECASE`
- `re.LOCALE` for making common escapes follow locale 

## Functions <a name="toc-sub-tag-2"></a>
The python regex library has a variety of specific functions, which all have their best use cases:

### Splitting strings with `split` <a name="toc-sub-tag-3"></a>
We can call a similar method to the `str.split` builtin from the regex library, to split a string by regex pattern
```python
re.split(ptrn, data)
```
which returns a list of substrings, with the matched split pattern removed.

### Searching with `search` <a name="toc-sub-tag-4"></a>
This method returns the *first occurance* of the pattern, and thus can be useful (and cost effective) when trying to determine if the pattern exists within a string
```python
if re.search(ptrn, data):
  ...
```
This method returns a `re.Match` instance. The generalisation of this method is `findall`.

### Extracting groups with `findall` <a name="toc-sub-tag-5"></a>
For some regex pattern `ptrn`, we can extract the matches from `data` using
```python
matches = re.findall(ptrn, data)
``` 
In this case, `matches` is a list containing all matches groups.

### `finditer` <a name="toc-sub-tag-6"></a>
Like `findall` except retuns an iterator of non-overlapping matches. Empty matches are included, just as with `findall`. 

### Replacing with `sub` and `subn` <a name="toc-sub-tag-7"></a>
You can replace a pattern with a substring using 
```python
re.sub(ptrn, replacement, string, count=0)
```
If replacement is a string, it is escaped by default. If it is a callable, then the result must be a string. This method returns the new string, with no side-effects.

A variant to this is `subn`, which has an identical finger print, but also returns a tuple containing the new string and the number of substitutions made.
