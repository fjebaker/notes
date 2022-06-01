# Julia Scopes

<!--BEGIN TOC-->
## Table of Contents
1. [`let`](#let)
2. [`do`](#do)
3. [`begin`](#begin)

<!--END TOC-->

## `let`
The [scope created by `let`](https://docs.julialang.org/en/v1/manual/variables-and-scoping/#Let-Blocks) is purely a local scope, with variables being deallocated after the scope exits. As such, it will allocate every time the scope is executed.

From the docs
```jl
x, y, z = -1, -1, -1;

let x = 1, z
    println("x: $x, y: $y") # x is local variable, y the global
    println("z: $z") # errors as z has not been assigned yet but is local
end
```
This can be extremely useful in closure definitions; for example with mutable data structures like `Vectors`, we could have
```jl
vec = Vector{Function}(undef, 2)

i = 1;
while i <= 2
    # implicitly using global i
    vec[i] = () -> i 
    # explicitly using global i
    global i += 1
end
```
will return `3` for each element call. However, we can span the local scope `i` with a `let`-block
```jl
while <= 2
    let i = i # assigning current value of global i to local i
        # implicitly using local i
        vec[i] = () -> i
    end
    global i += 1
end 
```
will execute as expected.

## `do`
We can use `do` similarly(ish) to the Python `with` statement, as a wrapper for a context code block.

For example
```jl
open("file", "w") do io
    write(io, "Hello World")
end
```

Here, the use of `do` creates an anonymous function, with the implementation
```jl
function(io)
    write(io, "Hello World")
end
```
which is then passed as the *first argument* to the `open` call.

We could model our own such functions with something like
```jl
function read_file(f::Function, path::AbstractString)
    io = nothing
    try
        io = open(path, "r")
        f(io)
    catch err
        rethrow(err)
    finally
        if !isnothing(io)
            close(io)
        end
    end
end
```
To be used with something like 
```jl
read_file("file") do istream
    println(read(istream, String))
end
```

## `begin`
Using `begin` and `end` is the exact analogue for `{}` in C type languages, or indentation levels in Python -- it manages the most fundemental concept of the scope.

Usage is very straight forward

```jl
# anonymous function
func = x -> begin
    res = x(10)
    println("Result is $res")
end

# inplace use
func((v) -> begin
    v = v^2
    4 * v
end) # 400
```
