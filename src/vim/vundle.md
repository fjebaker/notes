# Vundle

[Vundle](https://github.com/VundleVim/Vundle.vim) is a package manager for Vim Plugins.

<!--BEGIN TOC-->
## Table of Contents
1. [Installation](#installation)

<!--END TOC-->

## Installation

To install
```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```
and then add
```vim
set nocompatible
filetype off

" Vundle plugin manager

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" Add plugins here


call vundle#end()
filetype plugin indent on
```
to your `.vimrc`.

Finalize the installation by starting vim and using the command `:PluginInstall`.


