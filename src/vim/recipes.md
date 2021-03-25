# Vim Recipes

One-liners and other useful tricks for Vim.

<!--BEGIN TOC-->
## Table of Contents
1. [To uppercase](#to-uppercase)
2. [Vim Regex](#vim-regex)

<!--END TOC-->

## To uppercase
We can turn all words uppercase using the search-and-replace regex:
```
%s/\<./\u&/g
```
Here 
- `\<` matches the start of a word
- `\u` is the Vim uppercase modifier, for the character in the substituted string (i.e. `&`, the LHS)


## Vim Regex
Useful overview is provided on [Vimregex](http://www.vimregex.com/).