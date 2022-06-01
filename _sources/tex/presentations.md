# Making presentations in LaTeX

I have my master's thesis *viva voce* tomorrow, and need to prepare a short \~10 minute presentation for the introduction. I thought I would use this as an opportunity to learn how to make presentation slides in LaTeX.

<!--BEGIN TOC-->
## Table of Contents
1. [The `beamer` package](#the-beamer-package)
    1. [Using sections and subsections](#using-sections-and-subsections)
    2. [Formatting individual slides](#formatting-individual-slides)
        1. [Blocks](#blocks)
        2. [Definitions](#definitions)
        3. [Lists](#lists)
        4. [Columns](#columns)
2. [Themes](#themes)
3. [Formatting table of contents](#formatting-table-of-contents)

<!--END TOC-->

## The `beamer` package
The general format of the document will be
```
\documentclass[xcolor=dvipsnames]{beamer}%
\usetheme{Antibes}%
\title{Cosmic string simulations}%
\author{Fergus Baker}%
\institute{Royal Holloway University of London}%

% -------------------------------------------- DOC START
\begin{document}

% -------------------------------------------- TITLE FRAME
\begin{frame}
\titlepage
\end{frame}

% -------------------------------------------- SLIDE
\begin{frame}
\frametitle{First slide}
Slide content
\end{frame}

% -------------------------------------------- DOC END
\end{document}
```
We define slides using the `frame` objects. Each slide is rendered with a task-bar at the bottom of the page for navigation. The document may be compiled easily with `pdflatex`.

### Using sections and subsections
Sections and subsections do not appear on the slides as headings, but rather in the slide metadata (located differently depending on the choice of theme). To define a section, we do so outside of a `frame`
```
\section{Motivation and aims}
\begin{frame}
% ...
```
The sections and subsections still interface with the table of contents, and can be displayed succinctly by including
```
\tableofcontents
```
either in a separate frame, or elsewhere.

### Formatting individual slides
Included here are some of the basic formatting types for LaTeX slides.
#### Blocks
You can use blocks to create emphasis on a `frame` with
```
\begin{block}{Background and axioms}
% ...
\end{block}
```
This will create a colourful block of tedt on the slide.
#### Definitions
Definitions are a special type of block, which have a different colour profile. They can be created with
```
\begin{definition}{Open string}
% ...
\end{block}
```
#### Lists
Similar to regular LaTeX, we can define a list with bullet-points as
```
\begin{itemize}
	\item Determine statistical relationships of the systems
	\begin{itemize}
		\setbeamertemplate{itemize items}[circle]
		\item Fractal dimension
		% ...
	\end{itemize}
\end{itemize}
```
or as a numbered list by exchanging `itemize` with enumerate. The starting value of enumerate can be set to, e.g., 3 by using `\setcounter{enumi}{3}` before the first `\item`. The count can be changed to letters be replacing `enumi` with `enumii`.

For `itemize` lists, the icon style may be changed using the `\beamertemplate` macro within the `\begin{itemize}` scope. The available options are
```
\setbeamertemplate{itemize items}[square]
\setbeamertemplate{itemize items}[triangle]
\setbeamertemplate{itemize items}[circle]
\setbeamertemplate{itemize items}[ball]			% circle with lighting effect
```

#### Columns
Using the `multicol` package, the slides can be split up easily. For example, creating a two column slide
```
\begin{frame}
\begin{columns}[T] % align columns
\begin{column}{.43\textwidth}
Left Column.
\end{column}

\begin{column}{.43\textwidth}
Right Column.
\end{column}%
\end{columns}
\end{frame}
```
## Themes
For my purpose, I slightly modified the `Antibes` theme for `beamer`; I wanted the infobar at the top only to display the title and section (but not the subsection). Following some examples from online
```
\makeatletter
\setbeamertemplate{headline}
{%
    \begin{beamercolorbox}[wd=\paperwidth,colsep=1.5pt]{upper separation line head}
    \end{beamercolorbox}
    \begin{beamercolorbox}[wd=\paperwidth,ht=2.5ex,dp=1.125ex,%
      leftskip=.3cm,rightskip=.3cm plus1fil]{title in head/foot}
      \usebeamerfont{title in head/foot}\insertshorttitle
    \end{beamercolorbox}
    \begin{beamercolorbox}[wd=\paperwidth,ht=2.5ex,dp=1.125ex,%
      leftskip=.3cm,rightskip=.3cm plus1fil]{section in head/foot}
      \usebeamerfont{section in head/foot}%
      \ifbeamer@tree@showhooks
        \setbox\beamer@tempbox=\hbox{\insertsectionhead}%
        \ifdim\wd\beamer@tempbox>1pt%
          \hskip2pt\raise1.9pt\hbox{\vrule width0.4pt height1.875ex\vrule width 5pt height0.4pt}%
          \hskip1pt%
        \fi%
      \else%  
        \hskip6pt%
      \fi%
      \insertsectionhead
    \end{beamercolorbox}
% Code for subsections removed here
}
\makeatother
```

## Formatting table of contents
I wanted my table of contents to split over two columns, so that the full text could be displayed on one side. To achieve this, I use
```
% -------------------------------------------- TOC FRAME
\begin{frame}
    \frametitle{Outline}
    \begin{columns}[t]
        \begin{column}{.65\textwidth}
            \tableofcontents[sections={1-4}]
        \end{column}
        \begin{column}{.35\textwidth}
            \tableofcontents[sections={5-7}]
        \end{column}
    \end{columns}
\end{frame}
```
where the numbers and column widths can be adjusted.