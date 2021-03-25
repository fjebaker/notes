# Software Design Principles

A short synopsis of common design principles.

<!--BEGIN TOC-->
## Table of Contents
1. [DRY](#dry)
2. [SOLID](#solid)
3. [POLA](#pola)
4. [KISS](#kiss)
5. [POLP](#polp)
6. [YAGNI](#yagni)

<!--END TOC-->


## DRY

- **D**on't
- **R**epeat
- **Y**ourself

Duplicate code is bad. If there are multiple copies of the same code, maintaining, or changing, the behaviour of a program can become seriously tricky. Instead, we try to eliminate any repeated lines, and merge them into a shared function that is (generically) reusable.

If code is not *entirely* identical, then redesign the components that use it so that we can prefer a common interface.

## SOLID

- **S**ingle responsibility principle
- **O**pen/Closed principle
- **L**iskov substitution principle
- **I**nterface segregation principle
- **D**ependency inversion principle

Analyzing each principle at a time:

*Single responsibility* states that every module, class, function, or otherwise, should only do one thing, and thus only have a single functional objective. This should reduce the size of components, make the code easier to understand, and, importantly, easy to test.

The *Open/Closed principle* states that every module should be *open* for extension but *closed* for modification. Existing components can then be easily reused in derived modules, and component design is loosely coupled, so that they can be replaced without affecting existing functionality.

*Liskov substitution principle* states that a routine which accepts type `T` can also accept type `S < T` without any change to the behaviour, or expected result, allowing a function to be reused for any subtype.

*Interface segregation* means a client does not need to implement interfaces they do not intend to use. New implementations are always available to construct when needed, and designed software components tend consequently to be more reusable and modular.

*Dependency inversion* is the idea that derived classes should not depend on low-level classes; high-level classes should only depend on an abstraction, implemented by the low-level classes. This way components are decoupled, allowing low-level components to be replaced or adjusted.


## POLA

- **P**rinciple
- **O**f
- **L**east
- **A**stonishment

Software should always be easy to understand and the behaviour should never be *astonishing* or surprising. Modules, classes, functions, etc., should be thoughftully named so that they are clear and unambiguous. Modules should be right-sized and well maintained. Interfaces should be small and understandable, and generally, try to minimize the number of functional arguments, in the interest of interprability by the user.

## KISS

- **K**eep
- **I**t
- **S**imple
- **S**tupid

It can be tempting to try and future-proof your software, and anticipate needs, however this can be a lot more effort, and can lead to excessive abstraction or bloated modules, making a system difficult to maintain, enhance, or even just use. Additionally, keeping code generic for the future can impact the performance of the code in the present.


## POLP

- **P**rinciple
- **O**f
- **L**east
- **P**rivilege

Clients must be given access only to the information or methods that they need; this helps keep applications secure, and allows for easier use of libraries. Generally, this means that sensitive data must be protected, and only exposing to privileged users reduces the number of test scenarios that must be anticipated; and together these make the system less prone to misuse.

## YAGNI

- **Y**ou
- **A**ren't
- **G**onna
- **N**eed
- **I**t

YAGNI means only develop the software needed today. Stemming from Ron Jeffries' blog:
> "Always implement things when you actually need them, never when you just foresee that you need them."

This links to KISS, in that future-proofing can prove more of a liability than a benefit. Functionality not needed by the customer will never be executed, so don't write it. The use-case may change, and mean the system must be redesigned or replaced entirely, so don't anticipate and write it. Or potentially a dependency may be discontinued, requiring a software rewrite, so don't think your software will need to be runnable forever. 

> The cheapest software is the one that you didn't write. You aren't gonna need it!
