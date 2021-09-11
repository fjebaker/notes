# Recommended talks
I watch a lot of talks about programming languages, paradigms, tools, compilers, etc., and decided I would start keeping track of the talks I thought were particularly good.

<!--BEGIN TOC-->
## Table of Contents
1. [C / C++](#c-/-c++)
    1. [Effective CMake - Daniel Pfeifer [C++Now 2017]](#effective-cmake---daniel-pfeifer-[c++now-2017])
    2. [Using Modern CMake Patterns to Enforce a Good Modular Design - Mathieu Ropert [CppCon 2017]](#using-modern-cmake-patterns-to-enforce-a-good-modular-design---mathieu-ropert-[cppcon-2017])
    3. [Monoids, Monads and Applicative Functors: Repeated Software Patterns - David Sankel [CppCon 2020]](#monoids,-monads-and-applicative-functors-repeated-software-patterns---david-sankel-[cppcon-2020])
    4. [What Everyone Should Know About How Amazing Compilers Are - Matt Godbolt [C++ on Sea 2019]](#what-everyone-should-know-about-how-amazing-compilers-are---matt-godbolt-[c++-on-sea-2019])
    5. [When a Microsecond is an Eternity: High Performance Trading Systems in C++ - Carl Cook [CppCon 2017]](#when-a-microsecond-is-an-eternity-high-performance-trading-systems-in-c++---carl-cook-[cppcon-2017])
2. [MongoDB](#mongodb)
    1. [Data Modeling with MongoDB - Yulia Genkina [MongoDB 2020]](#data-modeling-with-mongodb---yulia-genkina-[mongodb-2020])
3. [Go](#go)
    1. [Building a container from scratch in Go - Liz Rice [Container Camp 2016]](#building-a-container-from-scratch-in-go---liz-rice-[container-camp-2016])
4. [Linux](#linux)
    1. [Write and Submit your first Linux kernel Patch - Greg Kroah-Hartman [FOSDEM 2010]](#write-and-submit-your-first-linux-kernel-patch---greg-kroah-hartman-[fosdem-2010])
5. [Paradigms](#paradigms)
    1. [The Forgotten Art of Structured Programming - Kevlin Henney [C++ on Sea 2019]](#the-forgotten-art-of-structured-programming---kevlin-henney-[c++-on-sea-2019])

<!--END TOC-->

## C / C++

### Effective CMake - Daniel Pfeifer [C++Now 2017]
[YouTube link](https://www.youtube.com/watch?v=bsXLMQ6WgIk&ab_channel=CppNow).

### Using Modern CMake Patterns to Enforce a Good Modular Design - Mathieu Ropert [CppCon 2017]
[YouTube link](https://www.youtube.com/watch?v=eC9-iRN2b04&ab_channel=CppCon).

### Monoids, Monads and Applicative Functors: Repeated Software Patterns - David Sankel [CppCon 2020]
[YouTube link](https://www.youtube.com/watch?v=giWCdQ7fnQU).

### What Everyone Should Know About How Amazing Compilers Are - Matt Godbolt [C++ on Sea 2019]
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

### When a Microsecond is an Eternity: High Performance Trading Systems in C++ - Carl Cook [CppCon 2017]
[YouTube link](https://www.youtube.com/watch?v=NH1Tta7purM). Discussing fast coding practices for economic application, although the idioms discussed are applicable anywhere; also notes the importance of measurement and cache v. cores. Also touches on the cache warming technique, and shortens to "Keep the hot path hot".

- Slowpath Removal:

Avoid
```c++
if (checkErrorA()) 
    handleErrorA();
else if (checkErrorB())
    handleErrorB();
else if (checkErrorC())
    handleErrorC();
else
    sendOrderToExchange();
```
Aim for
```c++
int64_t errorFlags;
// ...
if (!errorFlags)
    sendOrderToExchange();
else
    HandleError(errorFlags);
```
Ensure that error handling code *is not* inlined. Use the `__attribute__` keywords with `always_inline` and `noinline` when appropriate:
```cpp
__attribute__((noinline))
void ComplexLoggingFunction() {
    // ...
}
```

- Template based configurations:

Virtual functions and simple branches can be expensive; a possible solution is to use templated functions. Removes branches, eliminates code that won't be executed. Example:
```c++
// 1st implementation 
struct OrderSenderA {
    void SendOrder() {
        // ...
    }
};
// 2nd implementation 
struct OrderSenderB {
    void SendOrder() {
        // ...
    }
};


template <typename T>
struct OrderManager : public IOrderManager {
    void MainLoop() final {
        // ...
        mOrderSender.sendOrder();
    }
    T mOrderSender;
};
```
Then use factories to parse configurations
```c++
std::unique_ptr<IOrderManager> Factory(const Config& config) {
    if (config.UseOrderSenderA())
        return std::make_unique<OrderManager<UseOrderSenderA>>();
    else
        return std::make_unique<OrderManager<UseOrderSenderB>>();
}

int main(int argc, char* argv[]) {
    auto manager = Factory(config);
    manager->MainLoop();
}
```

- Lambda functions are fast and convenient

If you know at compile time which function will be executed, then prefer lambdas
```c++
template <typename T>
void SendMessage(T&& lambda) {
    Msg msg = PrepareMessage();
    lambda(msg);
    send(msg);
}
```
With example lambda
```cpp
SendMessage([&](auto& msg) {
    msg.instrument = x;
    msg.price = z;
});
```

- Memory allocation

Allocations are costly; prefer a pool of preallocated objects. Reuse instead of deallocating. If you must delete large objects, consider using another thread (glibc `free` has 400 lines of book-keeping code).

- Use templates over branches
Instead of using `if`/`else` or ternary operators, prefer a templated approach:
```c++
template <Side T>
void Strategy<T>::RunStrategy() {
    const float orderPrice = CalcPrice(fairValue, credit);
    // ...
}

template<>
float Strategy<Side::Buy>::CalcPrice(float value, float credit) {
    return value - credit;
}
template<>
float Strategy<Side::Sell>::CalcPrice(float value, float credit) {
    return value + credit;
}
```

- Multithreading

Avoid for latency-sensitive code; synchronization of data via locking will get expensive, or lock-free code may require hardware locks.

If using multiple thread, keep *shared data to absolute minimum*. Consider passing data copies over sharing. If data must be shared, and out-of-sequence updates are acceptable, consider not synchronizing. 

- Data lookups

If the cache-line is 64 bits, adjust datastructures so commonly read values are ordered together -- in the following, looking up `price` gives `quantityMultiplier` for free: denormalized data is not a sin.
```c++
struct Instrument {
    float price;
    int16_t quantityMultiplier;
    // ...
}
```
Storing the same value in two places is not always bad practice.

- Keep the cache hot

Always execute to the last point of the hot-path to keep the cache warm, and as a bonus, to train the hardware branch predictor correctly. If possible, don't share L3, disable all but a single core (or lock the cache) -- if you do have multiple cores, choose neighbours carefully. Noisy neighbours may be moved to a different physical CPU if possible.

- Measurement

Tools: sampling profiler `gprof`, instrumentation profilers `callgrind`, microbenchmarks Google Benchmark, etc., all have their limitations; they are useful, but not for micro-optimization. Instead, try to as closely as you can model your server configuration and test on that.

- Summary:

Aim for very simple runtime logic, **compilers optimize simple code the best**. Prefer approximations over precision where appropriate; do the expensive work only when you have spare time. Conduct accurate measurements.

## MongoDB

### Data Modeling with MongoDB - Yulia Genkina [MongoDB 2020]
[YouTube link](https://www.youtube.com/watch?v=yuPjoC3jmPA&ab_channel=MongoDB). I've covered this talk in detail in [my MonogDB notes](https://github.com/fjebaker/notes/blob/master/databases/mongo-db.md).

## Go

### Building a container from scratch in Go - Liz Rice [Container Camp 2016]
[YouTube link](https://www.youtube.com/watch?v=Utf-A4rODH8&ab_channel=ContainerCamp). How container runtimes work, from an effective level.

- Demonstrates how you can use system flags to create namespaces, virtual directory structures, and process trees
- Live coding examples in GO

A very good talk for a solid understanding of how container runtimes work.

## Linux

### Write and Submit your first Linux kernel Patch - Greg Kroah-Hartman [FOSDEM 2010]
[YouTube link](https://www.youtube.com/watch?v=LLBrBBImJt4&ab_channel=FOSDEM).

## Paradigms

### The Forgotten Art of Structured Programming - Kevlin Henney [C++ on Sea 2019]
[YouTube link](https://www.youtube.com/watch?v=SFv8Wm2HdNM). On keeping code clean, factorisable, and the importance of intelligent control flow.

A cool (but legacy) code example demonstrating multiple entry points of a `while` directive
```C
send(to, from, count) 
register short *to, *from; 
register count;
{
    register n = (count + 7) / 8;
    switch (count % 8) {
        case 0: do {    *to = *from++; 
        case 7:         *to = *from++;
        case 6:         *to = *from++;
        case 5:         *to = *from++;
        case 4:         *to = *from++;
        case 3:         *to = *from++;
        case 2:         *to = *from++;
        case 1:         *to = *from++;
            } while (--n > 0);
    }
}
```

Key notes:

- don't use `goto`
- block structure is a great organizational tool
