# Vim Recipes
One-liners and other useful tricks for Vim.

<!--BEGIN TOC-->
## Table of Contents
1. [To uppercase](#0-To-uppercase)
2. [Vim Regex](#1-Vim-Regex)

<!--END TOC-->

## To uppercase <a name="0-To-uppercase"></a>
We can turn all words uppercase using the search-and-replace regex:
```
%s/\<./\u&/g
```
Here 
- `\<` matches the start of a word
- `\u` is the Vim uppercase modifier, for the character in the substituted string (i.e. `&`, the LHS)


## Vim Regex <a name="1-Vim-Regex"></a>
Useful overview is provided on [Vimregex](http://www.vimregex.com/).