# Batch renaming in Vim
Recipes for renaming multiple files with Vim.

<!--BEGIN TOC-->
## Table of Contents
1. [Using the Renamer plugin](#using-the-renamer-plugin)
    1. [Usage](#usage)

<!--END TOC-->

## Using the Renamer plugin
Using the [Vim Renamer](git clone https://github.com/qpkorr/vim-renamer) plugin, which we can install with Vundle
```
Plugin 'renamer.vim'
```
and running `:PluginInstall`.


### Usage
Navigate to directory with files and open Vim. Then
```
:Renamer
```
and edit the file names as you would like them to be, and commit the filenames with `:Ren`.




