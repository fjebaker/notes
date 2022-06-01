# Conan package manager

Conan is a package manager and repository for C and C++, well integrated into CMake.

<!--BEGIN TOC-->
## Table of Contents
1. [Example use](#example-use)

<!--END TOC-->

## Example use
(this section adapted from [a conan tutorial](https://docs.conan.io/en/latest/getting_started.html))

For a given dependency, we can search different remote repositories for the correct package and package version. E.g., for `poco` we search
```bash
conan search poco --remote=conan-center
```
The `--remote` flag can be shortened to `-r`, and to search all repositories, we use `-r=all`.

Individual search results can be analyses a little further in terms of their metadata using
```bash
conan inspect [item]
```

Once we've found a package we are happy with, we create a `conanfile.txt` in the root directory of the project. We format the file as
```
[requires]
packages/version

[generators]
cmake
```
in this example, we explicitly use `cmake`.

Next we want to install the dependencies. Note: conan will use old gcc compilers for backwards compatability `< 5.1`. We can change this using
```bash
conan profile new default --detect  # Generates default profile detecting GCC and sets old ABI
conan profile update settings.compiler.libcxx=libstdc++11 default  # Sets libcxx to C++11 ABI
```

To install
```bash
mkdir build && cd build
conan install ..
```

Conan install the requirements and the transitive dependencies for it seamlessly.

We can now define a `CMakeLists.txt`, and include the lines
```bash
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()
# add executable
target_link_libraries(md5 ${CONAN_LIBS})
```
and finally build
```bash
cmake .. -G "Unix Makefiles"
cmake --build .
```