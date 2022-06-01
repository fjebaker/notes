# On using `std::function` for member functions

<!--BEGIN TOC-->
## Table of Contents
1. [Overview](#overview)
2. [Pointers to class members](#pointers-to-class-members)
3. [Using `std::function`](#using-std-function)
    1. [With lambda wrappers](#with-lambda-wrappers)

<!--END TOC-->

## Overview

A colleague recently asked me about passing function pointers under different circumstances, so I thought I would write up a few explanatory notes, as it can be a little confusing.

Consider the code snippet
```cpp
class A {
  int factor;
public:
  A(int factor) : factor{factor} {}
  int invoke(int i) { return factor * i; }
};

int mult(int (*m_func)(int), int i) {
  return m_func(i);
}
```

If we wanted to pass the member function `A::invoke` to `mult` from a specific instance, we cannot just write
```cpp
int main() {
  int ret;
  A a(3); // set factor to 3

  ret = mult(&a.invoke, 3); // can't create non-const ptr to member function

  ret = mult(&a::invoke, 3); // nope! a is not a class

  ret = mult(&A::invoke, 3); // with a different signature maybe, but
                             // who's instance is it?
  return ret;
}
```
This will raise all sorts of compiler errors and will not compile. This is because creating references to member variables or functions is not as straight forward as using namespace functions.

A quick fix to the above is to make the member function `static`, so that it can be cast to the argument type `int(*)(int)`, however this is more often than not, not the ideal.

## Pointers to class members

Consider this example:
```cpp
struct B {
    int x;
};

int main() {
  B b;

  int B::*x_ptr = B::x; // pointer to name x in B

  b.*x_ptr = 3; // point to x in instance and assign

  return b.x; // will return 3
}
```

Here we create a pointer to the name in the class, i.e. `B::x`, which we can then use along with an instance to access a memory location containing a value of `B::x`, in this case `b.x`. You could consider `x_ptr` to be an offset pointer from `B`, which is used to access members from an instance.

So how could we apply this to functions? We now know how we can pass a function from a class, so we need to first adjust our `mult` function
```cpp
int mult(int (A::*m_func)(int), A& instance, int i) {
  return (instance.*m_func)(i);
}
```
and then use it with something like
```cpp
int main() {
  int ret;
  A a(3); // set factor to 3

  ret = mult(&A::invoke, a, 3); // pass a reference to the member function
  return ret; // returns 9
}
```
And in doing so, we can now pass any arbitrary function in `A` as an argument, and allow it to be called. However, this still isn't exactly ideal, as we've now limited the interface to only use member functions. Another approach, as mentioned in [this stack overflow answer](https://stackoverflow.com/a/12662961) would be to use a forwarding function and a `void*` context pointer. This is a very C-esque approach, and in C++ we can make use of either templated functions to account for a context, or, better yet, use the C++11 `functional` library.

## Using `std::function`
We can write an interface for `mult` that is now fairly similar to the original attempt, using the template arguments `<return_type(arg_type,...)>`:
```cpp
#include <functional>

int mult(std::function<int(int)> m_func, int i) {
  return m_func(i);
}
```
We can then use the [`std::bind`](https://en.cppreference.com/w/cpp/utility/functional/bind) to create a context-wrapped member function:
```cpp
int main() {
  int ret;
  A a(3); // set factor to 3

  auto func = std::bind(&A::invoke, a, std::placeholders::_1);
  ret = mult(func, 3);

  return ret;
}
```
This is still quite messy, but at least our `mult` function is now generic enough that it can accept non-member functions, or member functions from other classes, provided the signature matches.

### With lambda wrappers
Maybe the most elegant and readable way of writing the above `main` implementation is to use C++11 [lambda expressions](https://en.cppreference.com/w/cpp/language/lambda), allowing us to write something like
```cpp
int main() {
  int ret;
  A a(3); // set factor to 3

  ret = mult([&](int i) { return a.invoke(i); }, 3);
  return ret;
}
```

As a note, I would *encourage* the use of trailing return types when using lambdas in this way, as it is not immediately obvious what or sometimes even *if* a lambda returns. Thus, would use
```cpp
ret = mult([&](int i) -> int { return a.invoke(i); }, 3);
```

An additional benefit of using lambda wrappers is that the compiler can heavily optimise lifetime considerations. For example, the above written with `std::bind` generates around 1200 lines of assembly with a considerably longer `main`, whereas the lambda case only generates 500 lines, with a highly reduced `main`.
