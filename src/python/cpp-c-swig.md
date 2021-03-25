# Wrapping C/C++ code using SWIG

The Simplified Wrapper and Interface Generator (SWIG) is a tool for wrapping C/C++ code into a variety of higher level languages, including JS, Python, Ruby, etc., and is used alongside interface files which help instruct the SWIG pre-compiler which methods and functions should be exposed.

<!--BEGIN TOC-->
## Table of Contents
1. [SWIG setups](#swig-setups)
    1. [Python](#python)
        1. [Useful command line options](#useful-command-line-options)
2. [Python Packages](#python-packages)
3. [Binding abstractions](#binding-abstractions)
    1. [Pointers](#pointers)
    2. [Structures](#structures)
    3. [Classes](#classes)
4. [numpy](#numpy)
5. [A worked example: Python](#a-worked-example:-python)
    1. [SWIG CLI](#swig-cli)
    2. [Distutils](#distutils)

<!--END TOC-->

The official [SWIG Tutorial](http://swig.org/tutorial.html) covers how to get started quickly with SWIG, however my notes will elucidate a few more applied scenarios for SWIG which I will document as I continue to learn the tool myself.

A note is that SWIG does not support the full C++ syntax ([see here](http://swig.org/Doc3.0/SWIGPlus.html#SWIGPlus_nn4)), but still provides enough of the language support, and implicit conversion, that make most of the use cases straight forward to use.

The main difference when using C++ over C with SWIG is to include the relevant flag:

```bash
swig -c++ -python example.i 
```

## SWIG setups
In this section are the interface changes required for compiling to different higher level languages.

### Python
In the interface file, we must define
```C
#define SWIG_FILE_WITH_INIT
```
during the include sections, such that SWIG compiles the code into a Python compatible module.

The `setup.py` basic configuration follows the usual idiom (see the worked example below). To compile the external package to another name we use the setup keyword
```py
ext_package='some_other_name'
```
*NOTE:* I can't fully figure out an elegant solution for doing the above when not using explicit packaging (see Python Packages below). Instead, changing the module name in the interface file, and *prefixing* the python Extension with an underscore achieves the same result.

#### Useful command line options
- `-builtin`: create python built-in types rather than proxy classes for better performance
- `-doxygen`: convert C++ doxygen comments to pydoc comments in proxy classes
- `-interface <mod>`: set low-level C/C++ module name to `<mod>` (default: module name prefixed by an underscore)
- `-py3`: generate code with python3 specific features
- `-O`: enable the `-fastdispatch`, `-fastproxy`, `-fvirtual` optimizations

## Python Packages

To mimic the package hierarchy of python, SWIG provides the `package` keyword in the module definition
```C
%module(package="some_package") module_name
```
which would map to an import
```py
import some_package.module_name
```

Consider the following example project structure:
```
hello/
    world.c
    world.h
    world.i

setup.py
```
where the contents of `world.i` defines the module `world` under the package `hello`, along the lines of
```C
// hello/world.i
%module(package="hello") world

%{
    #define SWIG_FILE_WITH_INIT
    #include "example.h"
%}

// functions-to-wrap declerations, e.g.
int foo();
```

We then define a `setup.py` file to build the extension with
```py
from distutils.core import setup, Extension

example_module = Extension(
    '_world',
    sources=[
        'hello/example_wrap.c',
        'hello/example.c'
    ],
    language='c'
)

setup(
    name='example',
    version='0.1',
    ext_package='hello', # !important
    ext_modules=[
        example_module
    ]
)
```

The full installation procedure is then the usual
```bash
swig -python -py3 hello/world.i \
    && python setup.py build_ext --inplace
```
where *in theory* after the call to swig has been made, generating the relevant `*_wrap.c` and `*.py` files, we could bundle and ship the files and allow someone without swig to build the package with only the call to `setup.py`.

It can then be used with
```py
>>> import hello.world 
>>> hello.world.foo()
0
```

This recipe could then be extended for arbitrary package structure and/or modules, where we define a single interface `.i` file *for each* module in the package.

## Binding abstractions
The SWIG documentation lists how many higher-level classes and types in python are mapped to C/C++ types and classes.

### Pointers
Pointer bindings [here](http://swig.org/Doc3.0/Python.html#Python_nn18).
### Structures
Structure bindings [here](http://swig.org/Doc3.0/Python.html#Python_nn19).
### Classes
Class bindings [here](http://swig.org/Doc3.0/Python.html#Python_nn20).
How SWIG generates shadow classes and mappings [here](http://swig.org/Doc3.0/Python.html#Python_nn28).

## numpy
Using [numpy in SWIG](https://numpy.org/doc/stable/reference/swig.interface-file.html#summary) is also fairly straight forward, and only requires a few modifications to the recipe. First of all, in the interface file for the module, we need to include the `numpy.i`, available [here](https://github.com/numpy/numpy/blob/master/tools/swig/numpy.i), call the relevant `init` function, and define type maps; overall, we modify with the additional 
```C
%include "numpy.i"

%init %{
    import_array();
%}

// define a custom type map
%apply (double* IN_ARRAY1, int DIM1) {(double* arr, int length)};
```
*NB:* the type mapping must match by name *and* type in the function signature; i.e.
```C
double some_function(double* arr, int length);
```
will correctly accept an single dimensional `ndarray` as an argument, however
```c
double some_other_function(double* a, int b);
```
will not.

More information on the type mapping can be found under [available typemaps](https://numpy.org/doc/stable/reference/swig.interface-file.html#available-typemaps) in the documentation.

When defining our extension in `setup.py`, we now need to include the relevant numpy header files:
```py
import numpy as np 

Extension(
    #...
    include_dirs=[
        np.get_include()
    ]
)
```
The build commands are identical to before.

## A worked example: Python
Following from [the documentation](http://swig.org/Doc3.0/Python.html#Python).

We create three files
```cpp
// example.cpp

#include "example.hpp"

int fact(int n) {
    if (n < 0){ /* This should probably return an error, but this is simpler */
        return 0;
    }
    if (n == 0) {
        return 1;
    }
    else {
        /* testing for overflow would be a good idea here */
        return n * fact(n-1);
    }
}
```
with header
```cpp
// example.hpp

#ifndef EXAMPLE_HPP
#define EXAMPLE_HPP

int fact(int n);

#endif
```
And then the SWIG interface file:
```C
// example.i
%module example

%{
    #define SWIG_FILE_WITH_INIT
    #include "example.hpp"
%}

int fact(int n);
```

### SWIG CLI

We can then compile the wrapped C++ code for Python with 
```bash
swig -python -c++ example.i
```
which generates an `example_wrap.cxx`, and an `example.py`, i.e. the low level C/C++ code, and the high level wrapping support.

The module name defined by the line
```C
%module example
```
is used as a prefix for the output files.

### Distutils
We can use Distutils to compile and build the extension modules generated by the SWIG CLI. Disutils, in short,
> takes care of making sure that your extension is built with all the correct flags, headers, etc. for the version of Python it is run with.

To use it, we define a `setup.py` file
```py
# setup.py

from distutils.core import setup, Extension

example_module = Extension(
    '_example', # convention to prefix with underscore
    sources=[
        'example_wrap.c',
        'example.c'
    ],
    language='c++'
)

setup(
    name='example',
    version='0.1',
    ext_modules=[example_module],
    py_modules=['example']
)
```
We invoke the build with
```bash
python setup.py build_ext --inplace
```
where the `--inplace` flag specifies to compile the binaries into the current working directory, instead of within the build hierarchy.
