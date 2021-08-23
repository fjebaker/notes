# Vim Recipes

One-liners and other useful tricks for Vim.

<!--BEGIN TOC-->
## Table of Contents
1. [Installing `.vba` / vimball plugins](#installing--vba-/-vimball-plugins)
2. [Filetype specific settings](#filetype-specific-settings)
3. [To uppercase](#to-uppercase)
4. [Vim Regex](#vim-regex)
5. [Useful plugins](#useful-plugins)


<!--END TOC-->

## Installing `.vba` / vimball plugins
Open the file in vim and execute
```
:source %
```
This will move all of the plugins to their respective directory.

## Filetype specific settings

A good way of managing file specific settings is to use the [`filetype` plugin](https://vim-jp.org/vimdoc-en/filetype.html#:filetype-plugin-on): in short, add 
```
filetype plugin on
```
to your `.vimrc` file. Then, configure each filetype's settings in `~/.vim/ftplugin/`. For example, a configuration for UNIX Makefiles
```vim
" ~/.vim/ftplugin/make.vim
set ts=8
set sw=8
set noexpandtab
```

More information in the [Vim Fandom](https://vim.fandom.com/wiki/Keep_your_vimrc_file_clean).

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

## Useful plugins

- DrawIt for creating ASCII diagrams [link](https://www.vim.org/scripts/script.php?script_id=40)

- Renamer for batch renaming files [link](https://www.vim.org/scripts/script.php?script_id=1721)