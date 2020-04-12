# Declarations in C++

I used to spend a lot of time reading and watching conferences on the C++ programming language, and learned a lot about efficiently declaring functions in the modern C++20 compiler. In these notes I hope to explain my understanding of different concepts in declarations.

<!--BEGIN TOC-->
## Table of Contents
1. [Method `= 0`](#toc-sub-tag-0)
2. [Constructor or destructor `= default`](#toc-sub-tag-1)
3. [Using `noexcept`](#toc-sub-tag-2)
4. [`volatile`](#toc-sub-tag-3)
5. [`constexpr` vs `const`](#toc-sub-tag-4)
	1. [`const` in method definitions](#toc-sub-tag-5)
6. [`final`](#toc-sub-tag-6)
7. [Deep and shallow copies](#toc-sub-tag-7)
	1. [The `excplicit` keyword](#toc-sub-tag-8)
8. [Functional arguments](#toc-sub-tag-9)
9. [Good templating practices](#toc-sub-tag-10)
<!--END TOC-->

## Method `= 0` <a name="toc-sub-tag-0"></a>
Pure virtual

## Constructor or destructor `= default` <a name="toc-sub-tag-1"></a>

## Using `noexcept` <a name="toc-sub-tag-2"></a>

## `volatile` <a name="toc-sub-tag-3"></a>
Compilers often try to make many optimizations to the written code. An example is, if no attempt is made to modify some integer `num`, it may be try to change
```cpp
while(num == 0) {
	// ...
}
```
to just
```cpp
while (true) {
	// ...
}
```
to save having to retrieve and make the comparison (up to two operations). The compiler doesn't always 'see' all the code though, and a modification to `num` may be made outside of the code (e.g. in asynchronous or multi-threaded code). In this case, we can use the `volatile` keyword to tell the compiler **not** to optimize code involving this value
```cpp 
volatile int num = 0;
```

Note that structs declared as `volatile` extends to all of the members also (see a SO thread [here](https://stackoverflow.com/questions/4479597/does-making-a-struct-volatile-make-all-its-members-volatile/4479652)).

## `constexpr` vs `const` <a name="toc-sub-tag-4"></a>

### `const` in method definitions <a name="toc-sub-tag-5"></a>

## `final` <a name="toc-sub-tag-6"></a>

## Deep and shallow copies <a name="toc-sub-tag-7"></a>

### The `excplicit` keyword <a name="toc-sub-tag-8"></a>

## Functional arguments <a name="toc-sub-tag-9"></a>

## Good templating practices <a name="toc-sub-tag-10"></a>