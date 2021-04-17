# Bash reference

Reference notes for all things related to the Bourne Again Shell, and derivatives.

<!--BEGIN TOC-->
## Table of Contents
1. [Special variables](#special-variables)
    1. [Positional parameters](#positional-parameters)
2. [IFS](#ifs)
3. [Useful resources](#useful-resources)

<!--END TOC-->

## Special variables
Most of these are taken from [an advanced scripting guide](https://tldp.org/LDP/abs/html/internalvariables.html).

- **`$$`**: process ID, often the same as `$BASHPID`, contextually of the executing script.
- **`$MACHTYPE`**: machine hardware type (i386, x86_64, ...).
- **`$_`**: set to the final argument of the previously executed command.

For `$_`, consider
```bash
du > /dev/null
echo $_
# du

ls -l > /dev/null
echo $_
# -l
```

### Positional parameters
Only avaible in function calls

- **`$#`**: the number of arguments passed.
- **`$*`**: all positional parameters as a single word.
- **`$@`**: `$*` but with each parameter being seen as a seperate word.


The `$@` variable responds to `shift` calls, which removes `$1` and decrements the positional index of every remaining variable by one.

For example, a script which is passed `1 2 3 4 5` as input:
```bash
echo "$@"    # 1 2 3 4 5
shift
echo "$@"    # 2 3 4 5
shift
echo "$@"    # 3 4 5
```

## IFS
The *internal field seperator* is used by many shell commands to work out how to do word splitting in the input.

A useful case to remember is that *new-line* characters are escaped
```bash
IFS=$'\n'
```

The first character in the IFS definition also marks how common shell commands will bind words together. For example
```bash
IFS=":;-"
```
and
```bash
IFS="-:;"
```
will both split words on any of `:`, `;`, or `-` characters -- but when used with the `$*` special variable have a different effect:
```bash
bash -c 'set a b c d; IFS=":;-"; echo "$*" '
# a:b:c:d
bash -c 'set a b c d; IFS="-:;"; echo "$*" '
# a-b-c-d
```


## Useful resources

Resources for writing bash scripts, and general bash guides:

- Mendel Cooper's *Advanced Bash-Scription Guide* (site, available [here](https://tldp.org/LDP/abs/html/index.html)).