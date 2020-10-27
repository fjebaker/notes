# Using SWIG with CMake
There is a [UseSWIG](https://cmake.org/cmake/help/latest/module/UseSWIG.html) file providing support in CMake for system-installed SWIG, providing new bindings and methods for use in the project.


## Building with CMake
As usual, developing with OSX, SWIG 4.0.2, CMake 3.18.4. Consider the example project structure
```
src
├── CMakeLists.txt
├── example.cpp
├── example.hpp
└── py
    ├── CMakeLists.txt
    ├── example.i
    └── setup.py.in
CMakeLists.txt
venv/
```
We use a virtual environment, since on OSX the hardened code security prevents local imports with `dlopen`, thus we *must* install it into the environment (or have some wacky absolute paths).

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.18)
project(my_proj)

find_package(Python)

set(EXAMPLE_SRC
  example.cpp
)
add_library(example_lib STATIC ${EXAMPLE_SRC})
add_subdirectory(swig)
```

```cmake
# py/CMakeLists.txt
cmake_minimum_required(VERSION 3.18)
project(my_proj)

find_package(SWIG REQUIRED)
include(${SWIG_USE_FILE})
SET(CMAKE_SWIG_FLAGS "")

set_property(SOURCE example.i PROPERTY CPLUSPLUS ON)

include_directories(
  "."
  "${PYTHON_INCLUDE_DIRS}"
)

# build swig wrapper code
SET(UseSWIG_TARGET_NAME_PREFERENCE STANDARD)

# add target
SWIG_ADD_LIBRARY(example
  TYPE SHARED
  LANGUAGE python
  OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}
  SOURCES example.i
)

set_property(TARGET example
  PROPERTY
  SUFFIX ".so" # probably OS specific
)

target_link_libraries(example PRIVATE example_lib ${PYTHON_LIBRARIES})

set(PYTHON_INSTALL_FILES
  ${CMAKE_CURRENT_BINARY_DIR}/cadabra_translator.py
  ${CMAKE_CURRENT_BINARY_DIR}/_cadabra_translator.so
)

# configure setup.py and copy to output dir
set(SETUP_PY_IN ${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in)
set(SETUP_PY_OUT ${CMAKE_CURRENT_BINARY_DIR}/setup.py)

configure_file(${SETUP_PY_IN} ${SETUP_PY_OUT})
```


```py
# py/setup.py.in
import setuptools.command.install
import shutil
from distutils.sysconfig import get_python_lib

from setuptools import find_packages, setup

class CompiledLibInstall(setuptools.command.install.install):
    """ specialized installation class """

    def run(self):
        """ called by setup """
        # Get filenames from CMake variable
        filenames = '${PYTHON_INSTALL_FILES}'.split(';')

        # Directory to install to
        install_dir = get_python_lib()

        # Install files
        [shutil.copy(filename, install_dir) for filename in filenames]


if __name__ == '__main__':
    setup(
        name='example',
        version='1.0.0',
        packages=find_packages(),
        cmdclass={'install': CompiledLibInstall}
    )
```

## Building with Setuptools
