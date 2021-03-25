# Julia Notes

I have created a seperate repository [julia-notes](https://github.com/Dustpancake/julia-resources) where I will be documenting my exploration of the Julia language.

I will use this directory as a link and overview, with some special language features highlighted, and recipes included. 

As always, this repository is a work in progress.

<!--BEGIN TOC-->
## Table of Contents
1. [Working notes](#working-notes)
2. [Project Templating](#project-templating)
3. [On `using` vs `import` vs `include`](#on-using-vs-import-vs-include)

<!--END TOC-->

## Working notes

- Abstract typing in Julia is not a specification of data structure, and can indeed be field-less. Abstract types model behaviour for a set hierarchy.

## Project Templating
For example, with `PkgTemplate` for creating the directory structure for a package:
```jl
using Pkg

Pkg.add("PkgTemplates")
using PkgTemplates

template = Template(; user="dustpancake")
```

And generate the project structure with
```jl
generate(template, "ProjectName")
```
Which will generate a new project in `~/.julia/dev/`, but can be changed with the `dir` keyword in `Template`.

## On `using` vs `import` vs `include`
In general, `using` when you are using the functionality, and `import` when you are intending to extend. `include` is different, in the sense of a C-like directive, which will "copy" the source code into the module, and becomes accessible as an extension; i.e.
```jl
module Something

using ModuleIwillUse

import ModuleIwillExtend

include("SubModuleIwantToExpose.jl")

end
```
