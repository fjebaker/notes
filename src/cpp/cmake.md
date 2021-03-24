# CMake notes
Notes from the field on CMake.

## Packages
CMake is able to locate packages with the [`find_package` directive](https://cmake.org/cmake/help/v3.19/command/find_package.html). This method operates in two different modes, namely `CONFIG` and `MODULE`, and in doing so sets a number of variables, including `<PACKAGE>_FOUND`, so that we can check that we successfully located the package. The [search procedure](https://cmake.org/cmake/help/v3.19/command/find_package.html#search-procedure) describes how these packages are resolved. In short, if we are using an internal (i.e. in the project folder located) package, we want to either name the directory identically to the `find_package` name, else provide the additional name with the `NAME` flag in `find_package`. An example use is then

```cmake
find_package(some_package COMPONENTS component1 component2 NAME alias REQUIRED)
```
which can then be system agnostically located in `some_package/` at root level. Note that each OS may require a different directory hierarchy within the package, but if you are writing one yourself, you need only include, at minimum, a `cmake` directory within it, containing the `Find*.cmake` or `*Config.cmake` files.

Note that the above applies for `CONFIG` mode. `MODULE` mode is a more simple use, which will often then define include directories and paths.

In either case, the packages must later be linked with `link_libraries` or `target_link_libraries`.
