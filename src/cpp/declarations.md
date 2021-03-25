# Declarations in C++

I used to spend a lot of time reading and watching conferences on the C++ programming language, and learned a lot about efficiently declaring functions in the modern C++20 compiler. In these notes I hope to explain my understanding of different concepts in declarations.

<!--BEGIN TOC-->
## Table of Contents
1. [Method `= 0`](#method-=-0)
2. [Constructor or destructor `= default`](#constructor-or-destructor-=-default)
3. [Using `noexcept`](#using-noexcept)
4. [`volatile`](#volatile)
5. [`constexpr` vs `const`](#constexpr-vs-const)
    1. [`const` in method definitions](#const-in-method-definitions)
6. [`final`](#final)
7. [Deep and shallow copies](#deep-and-shallow-copies)
    1. [The `excplicit` keyword](#the-excplicit-keyword)
8. [Functional arguments](#functional-arguments)
9. [Good templating practices](#good-templating-practices)

<!--END TOC-->

## Method `= 0`
Pure virtual

## Constructor or destructor `= default`

## Using `noexcept`

## `volatile`
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

## `constexpr` vs `const`

### `const` in method definitions

## `final`

## Deep and shallow copies

### The `excplicit` keyword

## Functional arguments

## Good templating practices