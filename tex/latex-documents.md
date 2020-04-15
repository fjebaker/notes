# Writing LaTeX documents
For my degree, and generally, I write a lot of articles in LaTeX. Often I find myself having to refer to previous documents, so I thought I would include skeletal document here.

<!--BEGIN TOC-->
## Table of Contents
1. [Templates](#toc-sub-tag-0)
2. [Listings](#toc-sub-tag-1)
3. [Commonly used snippets](#toc-sub-tag-2)
	1. [Creating lists](#toc-sub-tag-3)
	2. [Figures](#toc-sub-tag-4)
4. [Meta formatting](#toc-sub-tag-5)
	1. [Table of contents and appendix](#toc-sub-tag-6)
<!--END TOC-->

## Templates <a name="toc-sub-tag-0"></a>
List of templates for different LaTeX document types (this will grow as I update my notes)

- [Scientific articles](https://github.com/Dustpancake/Dust-Notes/blob/master/tex/templates/article.tex)
- [Scientific `baposter`](https://github.com/Dustpancake/Dust-Notes/blob/master/tex/templates/baposter.tex)

## Listings <a name="toc-sub-tag-1"></a>
Using code snippets is something often required in scientific writing. My general format for listings is
```tex
\definecolor{codebg}{gray}{0.8}%
\definecolor{codegreen}{rgb}{0,0.6,0}%
\definecolor{codegray}{rgb}{0.5,0.5,0.5}%
\definecolor{codepurple}{rgb}{0.58,0,0.82}%
\definecolor{backcolour}{rgb}{0.97,0.96,0.96}%
\lstdefinestyle{mystyle}{%
    backgroundcolor=\color{backcolour},%   
    commentstyle=\color{codegreen},%
    keywordstyle=\color{blue},%
    numberstyle=\tiny\color{codegray},%
    stringstyle=\color{codepurple},%
    basicstyle=\footnotesize\ttfamily,%
    breakatwhitespace=false,%         
    breaklines=true,%                 
    captionpos=b,%                    
    keepspaces=true,%                 
    numbers=left,%                    
    numbersep=5pt,%                  
    showspaces=false,%                
    showstringspaces=false,%
    showtabs=false,%                  
    tabsize=4%
}%
\lstset{style=mystyle}% 
```
Listings can be included using
```tex
\begin{lstlisting}[language]
sample code here
\end{lstlisting}
```
or used inline with
```tex
\lstinline{sample inline code}
```

## Commonly used snippets <a name="toc-sub-tag-2"></a>
I often find myself create a document fully of generic LaTeX extract for e.g. equations or figures, so that I can easily insert new items.

### Creating lists <a name="toc-sub-tag-3"></a>
For numerical lists, we can use
```tex
\begin{enumerate}
	\item first item
	\item second item
\end{enumerate}
```
If we require this to start at a specific number, e.g. 3, use `\setcounter{enumi}{3}`, and for alphabetical counters, use `enumii` in the setcounter prearg.

Bullet point lists are create in a similar fashion, with 
```tex
\begin{itemize}
	\item first item
	\item second item
\end{itemize}
```

### Figures <a name="toc-sub-tag-4"></a>
Single figures I include with the generic
```tex
\begin{figure}[h!]
\centering
\includegraphics[scale=1.0]{imagepath}
\captionsetup{format=hang}
\caption{sample caption text}
\label{fig:label}
\end{figure}
```
For figures with multiple subfigures, I use the `subfig` package, and the generic
```tex
\begin{figure}[h!]
\centering
\subfloat[subcaption1]{{\includegraphics{image1}}}\hspace{30pt}%
\subfloat[subcaption2]{{\includegraphics{image2}}}\hspace{30pt} \\%
\subfloat[subcaption3]{{\includegraphics{image3}}}%
\captionsetup{format=hang}
\caption{sample caption text}
\label{fig:label}
\end{figure}
```
I use `\hspace` to bad out the figure so that the figures are spaced nicely across the breadth of the page; these values are obviously tailored towards the specific images. If the subfigures do not require a caption, remove the `subcaption` text, but leave empty square brackets, else no alphabetical reference the subfigure will be rendered.

## Meta formatting <a name="toc-sub-tag-5"></a>
Formatting the overall look and feel of the document often requires changes in the preamble. Solutions to problems I often face are included here

### Table of contents and appendix <a name="toc-sub-tag-6"></a>
So that the appendix references in the ToC are preceded by 'Appendix A', and not just 'A', the following packages should be included
```tex
\usepackage{tocloft}%
\usepackage[titletoc]{appendix}%
\usepackage{appendix}%
```