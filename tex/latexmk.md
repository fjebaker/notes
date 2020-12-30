# Using `latexmk`
`latexmk` is a tool by John Collins for providing a simplified way of building LaTeX files in a system agnostic way.

<!--BEGIN TOC-->
## Table of Contents
1. [Configuration](#toc-sub-tag-0)
2. [Command line options](#toc-sub-tag-1)
<!--END TOC-->

Full manual is available [here](http://personal.psu.edu/~jcc8/software/latexmk/latexmk-469a.txt).

## Configuration <a name="toc-sub-tag-0"></a>
`latexmk` is configured either through `~/.latexmkrc` or locally to the project with a `.latexmkrc` or `latexmkrc` file.


A standard configuration for `latexmk` may look like
```perl
# nix: use okular; OSX can ommit this as the default is preview
$pdf_previewer = 'okular';


# use XeTeX as compiler for UTF-8 support
$pdf_mode = 5;
$latex = 'xelatex %O %S';
$pdflatex = 'xelatex %O %S';

# for bibtex, uncomment
$bibtex = 'bibtex %O %B';
$bibtex_use = 2;

$dvi_mode = 0; # disable .dvi generation
$postscript_mode = 0;	# no postscript files

@default_files = ('src.tex')

```

## Command line options <a name="toc-sub-tag-1"></a>
Here are a view useful command line options to use with `latexmk`:

- `-pvc`: enable hot reloading in the pdf previewer of choice
- `-c`: clean the current directory of latex intermediate files
- `-pdf`: use the `$pdflatex` specified compiler
- `-xelatex`: explicitly use the XeLaTeX compiler