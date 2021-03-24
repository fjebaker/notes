# Creating posters in LaTeX
Some poster packages and templates can be found [here](https://www.latextemplates.com/cat/conference-posters). The aim for me as of time of writing was to create an A0 poster for my master's thesis.

The skeletal poster structure templates will be available here

- [A0 baposter](https://github.com/Dustpancake/Dust-Notes/blob/master/tex/templates/baposter.tex)

<!--BEGIN TOC-->
## Table of Contents
1. [Overall structure](#toc-sub-tag-0)
	1. [The `\headerbox` command](#toc-sub-tag-1)
	2. [Figures](#toc-sub-tag-2)
2. [Formatting options](#toc-sub-tag-3)
	1. [Background image](#toc-sub-tag-4)
	2. [Making the content boxes transparent](#toc-sub-tag-5)
	3. [Including the bibliography](#toc-sub-tag-6)
	4. [Font sizes](#toc-sub-tag-7)
<!--END TOC-->


## Overall structure <a name="toc-sub-tag-0"></a>
I opted to use the `baposter` template, which relies on a grid based format for designing posters. We define a set number of header boxes, their location and relation to one another, and the content within. The following sections detail this process with examples.

### The `\headerbox` command <a name="toc-sub-tag-1"></a>
The headerbox is a box on the poster which has a header. We can define an arbitrary box with
```tex
\headerbox{TITLE OF THE BOX}{name=reference_name, column=0, row=0}{
	CONTENT
}
```
Other options to help format these boxes include 

- `span=[int]` for the column span
- `above=ref`, `below=ref` anchor the box above and below to another header box

### Figures <a name="toc-sub-tag-2"></a>
In general, float types do not tend to behave very well in `baposter`, and instead we use the `center` type; e.g., for two images
```tex
\begin{center}
\includegraphics[width=0.25\linewidth]{IMAGE1}
\includegraphics[width=0.25\linewidth]{IMAGE2}
\captionof{figure}{CAPTION}
\end{center}
```

## Formatting options <a name="toc-sub-tag-3"></a>
Here are some meta / general formatting options I've encountered using `baposter`.

### Background image <a name="toc-sub-tag-4"></a>
Setting a background image can be done in the preamble
```tex
\background{
\begin{tikzpicture}[remember picture,overlay]
\draw (current page.north west)+(-2em,2em) node[anchor=north west]
{\hspace*{-2cm}\includegraphics[height=1.1\paperheight, trim=0 0 0 0]{BACKGROUD_IMAGE}};
\end{tikzpicture}
}
```
Most of this command is fairly generic; the `\hspace*{-2cm}` is an arbitrary magic value to help shift and relocate the image a little, and should be tampered with to obtain the desired result.

### Making the content boxes transparent <a name="toc-sub-tag-5"></a>
I wanted my background image to ever so slightly show through into the header box content, so I found this solution to set a transparency value
```tex
\makeatletter % make boxes semi transparent
\renewcommand{\baposter@box@drawbackground@plain}[2]{\tikzset{box colors/.style={fill=#1,fill opacity=0.95}} \fill[box colors] \baposterBoxGetShape;}
\makeatother
```
where `opacity` controls the transparency.

### Including the bibliography <a name="toc-sub-tag-6"></a>
References in `baposter` behave the same as in any other LaTeX template, however a little extra boilerplate is required to make them visually appealing; I personally use
```tex
\renewcommand{\section}[2]{\vskip 0.05em}
```
to get rid of the "References" title, and then 
```tex
\bibliographystyle{ieeetr}
\bibliography{BIB IMAGE}
```
to include the references.

### Font sizes <a name="toc-sub-tag-7"></a>