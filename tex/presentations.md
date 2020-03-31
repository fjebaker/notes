# Making presentations in LaTeX
I have my master's thesis *viva voce* tomorrow, and need to prepare a short \~10 minute presentation for the introduction. I thought I would use this as an opportunity to learn how to make presentation slides in LaTeX.
<!--BEGIN TOC-->
## Table of Contents
1. [The `beamer` package](#toc-sub-tag-0)
	1. [Using sections and subsections](#toc-sub-tag-1)
	2. [Formatting individual slides](#toc-sub-tag-2)
		1. [Blocks](#toc-sub-tag-3)
		2. [Definitions](#toc-sub-tag-4)
		3. [Lists](#toc-sub-tag-5)
<!--END TOC-->
## The `beamer` package <a name="toc-sub-tag-0"></a>
The general format of the document will be
```
\documentclass[xcolor=dvipsnames]{beamer}%
\usetheme{Antibes}%
\title{Cosmic string simulations}%
\author{Fergus Baker}%
\institute{Royal Holloway University of London}%

% DOC START
\begin{document}

% TITLE FRAME
\begin{frame}
\titlepage
\end{frame}

% SLIDES
\begin{frame}
\frametitle{First slide}
Slide content
\end{frame}

% DOC END
\end{document}
```
We define slides using the `frame` objects. Each slide is rendered with a task-bar at the bottom of the page for navigation. The document may be compiled easily with `pdflatex`.

### Using sections and subsections <a name="toc-sub-tag-1"></a>
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

### Formatting individual slides <a name="toc-sub-tag-2"></a>
Included here are some of the basic formatting types for LaTeX slides.
#### Blocks <a name="toc-sub-tag-3"></a>
You can use blocks to create emphasis on a `frame` with
```
\begin{block}{Background and axioms}
% ...
\end{block}
```
This will create a colourful block of tedt on the slide.
#### Definitions <a name="toc-sub-tag-4"></a>
Definitions are a special type of block, which have a different colour profile. They can be created with
```
\begin{definition}{Open string}
% ...
\end{block}
```
#### Lists <a name="toc-sub-tag-5"></a>
Similar to regular LaTeX, we can define a list with bullet-points as
```
\begin{itemize}
	\item Some item text
	\begin{itemize}
		\item Some inner item text
	\end{itemize}
\end{itemize}
```
or as a numbered list by exchanging `itemize` with enumerate. The starting value of enumerate can be set to, e.g., 3 by using `\setcounter{enumi}{3}` before the first `\item`. The count can be changed to letters be replacing `enumi` with `enumii`.