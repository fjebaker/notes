# Julia Scopes

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
