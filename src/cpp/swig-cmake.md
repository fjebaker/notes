# Using SWIG with CMake

There is a [UseSWIG](https://cmake.org/cmake/help/latest/module/UseSWIG.html) file providing support in CMake for system-installed SWIG, providing new bindings and methods for use in the project.

<!--BEGIN TOC-->
## Table of Contents
1. [Building with CMake](#building-with-cmake)
2. [Building with Setuptools](#building-with-setuptools)

<!--END TOC-->


## Building with CMake
- *our aim is to install with pip, so we can manage the module conventiently*

As usual, developing with OSX, SWIG 4.0.2, CMake 3.18.4. Consider the example project structure
```
─ examplesrc
  ├── CMakeLists.txt
  ├── examplelib.cpp
  └── swig
      ├── CMakeLists.txt
      ├── example.i
      ├── MANIFEST.in
      └── setup.py.in

- CMakeLists.txt
- venv/
```
We use a virtual environment, since on OSX the hardened code security prevents local imports with `dlopen`, thus we *must* install it into the environment (or have some wacky absolute paths).


We start with the root cmake file:
```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.18)
project(my_proj)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -O2")

add_subdirectory(examplesrc)
```

Then, in our source directory we compile our pure C++ code into a statically linked library. In theory you could very well make this shared, but then would have to remember to install both ELFs in the `setup.py`.
```cmake
# examplesrc/CMakeLists.txt
cmake_minimum_required(VERSION 3.18)
project(example_proj)

message("Standard: ${CMAKE_CXX_STANDARD}")

set(examplelibsrc examplelib.cpp)

add_library(examplelib STATIC ${examplelibsrc})

add_subdirectory(swig)
```

Then finally, in the `swig` directory we write our wrapper script
```c
// examplesrc/swig/example.i
%module example

%{
  #define SWIG_FILE_WITH_INIT
  #include "examplelib.cpp" // use headers generally; source for this example
%}

// wrapper declarations
```
We incude from the local path, so we need to remember to tell cmake to include the correct directories. Implicit in this is also the relevant Python headers, which SWIG will need. To find these packages, and thus to compile our library, we need to locate the Python header files. CMake has a directive for us, `find_package`, which we also use to discover the SWIG tools.

Note that the package detection will locate the active virtual environment, provided we ran
```bash
source venv/bin/activate
```
before proceeding with the build.

The `find_packages` command will set common variables for us, including `<package>_FOUND` to check if cmake was able to successfully find the package. I have [written more notes on this directive](https://github.com/furges/notes/blob/master/cpp/cmake.md) for more details.

```cmake
# examplesrc/swig/CMakeLists.txt
cmake_minimum_required(VERSION 3.18)
project(my_proj)

find_package(Python COMPONENTS Development Interpreter)

if (Python_FOUND)
  message(${Python_SITELIB}) # print sitepath
else()
  message("No Python found.")
  return()
endif()

find_package(SWIG)
include(UseSWIG)

if(SWIG_FOUND)
  message("Found SWIG ${SWIG_VERSION}")
else()
  message("No SWIG found.")
  return()
endif()

set(UseSWIG_TARGET_NAME_PREFERENCE STANDARD)

set_property(SOURCE example.i PROPERTY CPLUSPLUS ON)

message("${CMAKE_SOURCE_DIR}/examplesrc")

include_directories("${CMAKE_SOURCE_DIR}/examplesrc" "${Python_INCLUDE_DIRS}")

# convenience variable
set(example_build_dir ${CMAKE_CURRENT_BINARY_DIR}/example)

swig_add_library(example
  TYPE SHARED
  LANGUAGE python
  OUTPUT_DIR ${example_build_dir} # important! else find_packages() wont find
  SOURCES example.i
)

set_property(TARGET example PROPERTY SUFFIX ".so")
# and again, so that the .so file is in the right place
set_property(TARGET example PROPERTY LIBRARY_OUTPUT_DIRECTORY ${example_build_dir})

target_link_libraries(example PRIVATE examplelib ${Python_LIBRARIES})

# ----------------------- installation specific ----------------------- #

# copy files
configure_file(setup.py ${CMAKE_CURRENT_BINARY_DIR}/setup.py COPYONLY)
configure_file(MANIFEST.in ${CMAKE_CURRENT_BINARY_DIR}/MANIFEST.in COPYONLY)

# and make it a module
install(CODE "file(COPY ${example_build_dir}/example.py ${example_build_dir}/__init__.py)")
# handle with pip
install(
  CODE "execute_process(WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} COMMAND ${Python_EXECUTABLE} -m pip install .)"
)
```
More details as to why e.g. `target_link_libraries` is used over `swig_link_libraries` can be found in the [documentation pages](https://cmake.org/cmake/help/latest/module/UseSWIG.html); in short, it is related to using the `STANDARD` name preference.

We write a minimal `setup.py` file:
```py
# examplesrc/swig/setup.py
from setuptools import setup, find_packages
print(find_packages())
if __name__ == "__main__":
    setup(
        name='example',
        version='1.0.0',
        packages=find_packages(),
        include_package_data=True
    )
```
and so that the binary `.so` file is included in the distribution, we also define
```
# MANIFEST.in
include example/*.so
```

- `make install`

When we run `make` a few things will now happen

- first, our library will be compiled as normally.
- then, SWIG will generate the wrapper code for python
- this wrapper is then compiled and statically linked with our library

During `make install`, two additional steps happen, as defined by the `install` directives in the above `CMakeLists.txt`

- copy `example.py` to `__init__.py` so that the wrapped code is at the root of the module namespace (*c.f.* `example.example.fact` vs `example.fact`).
- run the envionment specific `pip install`

In theory, you only need to cart around the `example` directory with a minimal
```
example
├── __init__.py
├── _example.so
└── example.py
```
for the module to work, but I have experienced issues with this on OSX, with regard to "hardened code".


## Building with Setuptools
Todo. :)
