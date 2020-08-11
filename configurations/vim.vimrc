syntax on
set number
set tabstop=4
set softtabstop=0
set noexpandtab
set shiftwidth=4
set tw=0
set textwidth=0 wrapmargin=0
set wrap

set nocompatible
filetype off


" Vundle plugin manager

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
" Add plugins here


Plugin 'renamer.vim'


call vundle#end()
filetype plugin indent on