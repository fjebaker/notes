# Recommended talks
I watch a lot of talks about programming languages, paradigms, tools, compilers, etc., and decided I would start keeping track of the talks I thought were particularly good.

<!--BEGIN TOC-->
## Table of Contents
1. [C / C++](#toc-sub-tag-0)
	1. [What Everyone Should Know About How Amazing Compilers Are - Matt Godbolt [C++ on Sea 2019]](#toc-sub-tag-1)
2. [Paradigms](#toc-sub-tag-2)
	1. [The Forgotten Art of Structured Programming - Kevlin Henney [C++ on Sea 2019]](#toc-sub-tag-3)
<!--END TOC-->

## C / C++ <a name="toc-sub-tag-0"></a>

### What Everyone Should Know About How Amazing Compilers Are - Matt Godbolt [C++ on Sea 2019] <a name="toc-sub-tag-1"></a>
[YouTube link](https://www.youtube.com/watch?v=w0sz5WbS5AM). Introduces and demos the website [Explorer Compiler](https://godbolt.org/), including examples of where the compiler optimizes (architecture dependent) even seemingly esoteric C++ code, and also how to ensure the compiler optimizes when trying non trivial implementation. Provides great overview of basic x86-64 registers and operations.

Key notes:

- compilers are cleverer than we are
- do not compromise readability for e.g. performance
- be aware of compiler limitations:
	- aliasing
		- use typing system
		- pass by value
		- avoid "raw" loops
	- visibility
		- "unknown" calls inhibit optimizations
		- `[[gnu::pure]]` and `[[gnu:const]]` (see this [SO question](https://stackoverflow.com/questions/29117836/attribute-const-vs-attribute-pure-in-gnu-c))
		- speculative devirtualisation
		- turn on link time optimization
	- structure layout
	- algorithms
- compiler cannot save you from bad data layout or algorithms

## Paradigms <a name="toc-sub-tag-2"></a>

### The Forgotten Art of Structured Programming - Kevlin Henney [C++ on Sea 2019] <a name="toc-sub-tag-3"></a>
[YouTube link](https://www.youtube.com/watch?v=SFv8Wm2HdNM)
On keeping code clean, factorisable, and the importance of intelligent control flow.

A cool (but legacy) code example demonstrating multiple entry points of a `while` directive
```C
send(to, from, count) 
register short *to, *from; 
register count;
{
	register n = (count + 7) / 8;
	switch (count % 8) {
		case 0:	do {	*to = *from++; 
		case 7: 		*to = *from++;
		case 6:			*to = *from++;
		case 5:			*to = *from++;
		case 4:			*to = *from++;
		case 3:			*to = *from++;
		case 2:			*to = *from++;
		case 1:			*to = *from++;
			} while (--n > 0);
	}
}
```

Key notes:

- don't use `goto`
- block structure is a great organizational tool
